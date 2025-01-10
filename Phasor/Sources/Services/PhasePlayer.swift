//
//  PhasePlayer.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/28/24.
//

import AVFoundation
import CoreMotion
import Foundation
import PHASE


// because writing this class from scratch just doesn't play audio! :)
/// Handles playing from SwiftData models by delegating to ``PhasePlayerFromUrl``
class PhasePlayer: ObservableObject {
    private let phasePlayerFromUrl = PhasePlayerFromUrl()

    func registerSoundAsset(_ soundAsset: SoundAsset) throws {
        // the overload that uses Data just gives me EXC_BAD_ACCESS every time
        // workaround for now is to write to a file and read it
        let tempUrl = URL.documentsDirectory.appending(path: soundAsset.id.uuidString)
        try soundAsset.data.write(to: tempUrl)
        
        try phasePlayerFromUrl
            .addSoundAsset(url: tempUrl, identifier: soundAsset.id.uuidString)
        
        // need to delete the temp file after finished
         try FileManager.default.removeItem(at: tempUrl)
    }

    func unregisterSoundAsset(_ soundAsset: SoundAsset) {
        phasePlayerFromUrl.removeAsset(identifier: soundAsset.id.uuidString)
    }

    func registerPlaybackSource(_ playbackSource: PlaybackSource) throws -> PHASESource {
        let transform = playbackSource.transform
        
        return try phasePlayerFromUrl.createPlaybackSource(transform: transform)
    }

    func registerSoundEvent(soundEvent: SoundEvent, source: PHASESource) throws -> PHASESoundEvent {
        return try phasePlayerFromUrl
            .createSoundEvent(
                source: source,
                soundEventAssetIdentifier: soundEvent.eventAsset.id.uuidString
        )
    }

    func registerSoundEventAsset(soundEventAsset: SoundEventAsset) throws {
        try phasePlayerFromUrl
            .createSoundEventAsset(
                soundEventAssetIdentifier: soundEventAsset.id.uuidString,
                // TODO: remove not nil assert
                soundAssetIdentifier: soundEventAsset.soundAsset!.id.uuidString,
                playbackMode: soundEventAsset.playbackMode,
                calibrationLevel: soundEventAsset.calibrationLevel,
                cullOption: soundEventAsset.cullOption
            )
    }
    
    func updateTransform(with newTransform: simd_float4x4) {
        phasePlayerFromUrl.listener.transform = newTransform
    }

    func loadProject(project: PhasorProject) throws {
        phasePlayerFromUrl.engine.defaultReverbPreset = project.reverbPreset
        
        let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(cullDistance: project.cullDistance)
        distanceModelParameters.rolloffFactor = project.rolloffFactor
        phasePlayerFromUrl.spatialMixerDefinition.distanceModelParameters = distanceModelParameters
        
        
        // register sound assets
        var uniqueSoundAssets: [SoundAsset] = []
        
        let soundAssets = project.soundEventAssets
            .map(\.soundAsset)
            .filter { $0 != nil }
        
        // sure why not
        for soundAsset in soundAssets {
            guard let soundAsset else { continue }
            var seen = false
            for existingSoundAsset in uniqueSoundAssets {
                if soundAsset == existingSoundAsset {
                    seen = true
                    break
                }
            }
            if !seen {
                try registerSoundAsset(soundAsset)
                uniqueSoundAssets.append(soundAsset)
            }
        }
        
        
        // register sound event assets
        try project.soundEventAssets
            .forEach { try registerSoundEventAsset(soundEventAsset: $0) }
        
        // register playback sources
        let sourceToPhase: [PlaybackSource: PHASESource] = project.playbackSources
            .reduce(into: [PlaybackSource: PHASESource]()) { dict, source in
                if let phaseSource = try? registerPlaybackSource(source) {
                    dict[source] = phaseSource
                }
            }

        // register sound events
        let phaseSoundEvents = try project.soundEvents
            .filter { sourceToPhase[$0.source] != nil}
            .map { soundEvent in
                try registerSoundEvent(
                    soundEvent: soundEvent,
                    // not nil assertion here since we checked in the filter
                    source: sourceToPhase[soundEvent.source]!
                )
            }
        
        phaseSoundEvents
            .forEach { $0.start() }
        
        try phasePlayerFromUrl.engine.start()
    }

    deinit {
        phasePlayerFromUrl.engine.stop()
    }
}
