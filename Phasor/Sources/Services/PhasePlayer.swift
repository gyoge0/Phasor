//
//  PhasePlayer.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/13/25.
//

import CoreMotion
import PHASE
import SwiftData
import SwiftUI

@Observable
class PhasePlayer {
    private let engine = PHASEEngine(updateMode: .automatic)
    private let hmm = CMHeadphoneMotionManager()
    private let listener: PHASEListener
    private let spatialMixerDefinition: PHASESpatialMixerDefinition
    private let spatialPipeline: PHASESpatialPipeline

    public private(set) var playbackSourceMap: [PlaybackSource: PHASESource] = [:]
    public private(set) var soundAssetList: [SoundAsset] = []
    public private(set) var soundEventAssetMap: [SoundEventAsset: PHASESoundEventNodeAsset] = [:]
    public private(set) var soundEventMap: [SoundEvent: PHASESoundEvent] = [:]

    public func registerSoundAsset(soundAsset: SoundAsset) -> Result<Void, any Error> {
        return Result {
            let tempUrl = URL.documentsDirectory.appending(path: soundAsset.id.uuidString)
            try soundAsset.data.write(to: tempUrl)
            try addSoundAsset(url: tempUrl, identifier: soundAsset.id.uuidString)
            soundAssetList.append(soundAsset)
            // need to delete the temp file after finished
            try FileManager.default.removeItem(at: tempUrl)
        }
    }

    private func addSoundAsset(url: URL, identifier: String) throws {
        try engine.assetRegistry.registerSoundAsset(
            url: url,
            identifier: identifier,
            assetType: .resident,
            channelLayout: nil,
            normalizationMode: .dynamic
        )
    }

    public func removeSoundAsset(soundAsset: SoundAsset) {
        removeAsset(identifier: soundAsset.id.uuidString)
    }

    public func removeSoundEventAsset(soundEventAsset: SoundEventAsset) {
        removeAsset(identifier: soundEventAsset.id.uuidString)
    }

    private func removeAsset(identifier: String) {
        engine.assetRegistry.unregisterAsset(identifier: identifier)
    }

    public func registerPlaybackSource(playbackSource: PlaybackSource) -> Result<(), any Error> {
        return Result {
            let phaseSource = try createPlaybackSource(
                transform: playbackSource.transform
            )
            playbackSourceMap[playbackSource] = phaseSource
        }
    }

    private func createPlaybackSource(transform: simd_float4x4) throws -> PHASESource {
        let source = PHASESource(engine: engine)

        source.transform = transform

        // Attach the Source to the Engine's Scene Graph.
        // This actives the Listener within the simulation.
        try engine.rootObject.addChild(source)

        return source
    }

    public func registerSoundEventAsset(soundEventAsset: SoundEventAsset) -> Result<(), any Error> {
        return Result {
            if !soundAssetList.contains(soundEventAsset.soundAsset) {
                try registerSoundAsset(soundAsset: soundEventAsset.soundAsset).get()
            }

            let phaseSoundEventAsset = try createSoundEventAsset(
                soundEventAssetIdentifier: soundEventAsset.id.uuidString,
                soundAssetIdentifier: soundEventAsset.soundAsset.id.uuidString,
                playbackMode: soundEventAsset.playbackMode,
                calibrationLevel: Double(soundEventAsset.calibrationLevel),
                cullOption: soundEventAsset.cullOption
            )

            soundEventAssetMap[soundEventAsset] = phaseSoundEventAsset
        }
    }

    private func createSoundEventAsset(
        soundEventAssetIdentifier: String,
        soundAssetIdentifier: String,
        playbackMode: PHASEPlaybackMode,
        calibrationLevel: Double,
        cullOption: PHASECullOption
    ) throws -> PHASESoundEventNodeAsset {
        // Create a Sampler Node from "drums" and hook it into the downstream Spatial Mixer.
        let samplerNodeDefinition = PHASESamplerNodeDefinition(
            soundAssetIdentifier: soundAssetIdentifier,
            mixerDefinition: spatialMixerDefinition
        )

        // Set the Sampler Node's Playback Mode to Looping.
        samplerNodeDefinition.playbackMode = playbackMode

        // Set the Sampler Node's Calibration Mode to Relative SPL and Level to 12 dB.
        samplerNodeDefinition.setCalibrationMode(
            calibrationMode: .relativeSpl,
            level: calibrationLevel
        )

        // Set the Sampler Node's Cull Option to Sleep.
        samplerNodeDefinition.cullOption = cullOption
        // Register a Sound Event Asset with the Engine named "drumEvent".
        let soundEventAsset = try engine.assetRegistry.registerSoundEventAsset(
            rootNode: samplerNodeDefinition,
            identifier: soundEventAssetIdentifier
        )

        return soundEventAsset
    }

    public func registerSoundEvent(soundEvent: SoundEvent) -> Result<PHASESoundEvent, any Error> {
        return Result {
            // this might not exist
            if playbackSourceMap[soundEvent.playbackSource] == nil {
                try registerPlaybackSource(
                    playbackSource: soundEvent.playbackSource
                ).get()
            }

            // this has to exist now
            let playbackSource = playbackSourceMap[soundEvent.playbackSource]!

            if soundEventAssetMap[soundEvent.soundEventAsset] == nil {
                try registerSoundEventAsset(
                    soundEventAsset: soundEvent.soundEventAsset
                ).get()
            }

            // this has to exist now
            let soundEventAsset = soundEvent.soundEventAsset

            let phaseSoundEvent = try createSoundEvent(
                source: playbackSource,
                soundEventAssetIdentifier: soundEventAsset.id.uuidString
            )
            phaseSoundEvent.start()
            soundEventMap[soundEvent] = phaseSoundEvent
            return phaseSoundEvent
        }
    }

    private func createSoundEvent(
        source: PHASESource,
        soundEventAssetIdentifier: String
    ) throws -> PHASESoundEvent {
        // Associate the Source and Listener with the Spatial Mixer in the Sound Event.
        let mixerParameters = PHASEMixerParameters()
        mixerParameters.addSpatialMixerParameters(
            identifier: spatialMixerDefinition.identifier,
            source: source,
            listener: listener
        )

        let soundEvent = try PHASESoundEvent(
            engine: engine,
            // this has to be the SOUND EVENT ASSET identifier
            assetIdentifier: soundEventAssetIdentifier,
            mixerParameters: mixerParameters
        )

        return soundEvent
    }

    public func updateTransform(with transform: matrix_float4x4) {
        listener.transform = transform
    }

    init() {
        self.listener = PHASEListener(engine: engine)
        // Set the Listener's transform to the origin with no rotation.
        self.listener.transform = matrix_identity_float4x4

        // Attach the Listener to the Engine's Scene Graph via its Root Object.
        // This actives the Listener within the simulation.
        try! engine.rootObject.addChild(self.listener)

        // Create a Spatial Pipeline.
        let spatialPipelineOptions: PHASESpatialPipeline.Flags = [
            .directPathTransmission, .lateReverb,
        ]
        self.spatialPipeline = PHASESpatialPipeline(flags: spatialPipelineOptions)!
        self.spatialPipeline.entries[PHASESpatialCategory.lateReverb]!.sendLevel = 0.1

        // Create a Spatial Mixer with the Spatial Pipeline.
        self.spatialMixerDefinition = PHASESpatialMixerDefinition(
            spatialPipeline: self.spatialPipeline
        )
    }

    func loadProject(project: PhasorProject) -> Result<(), Error> {
        engine.defaultReverbPreset = project.reverbPreset

        // Set the Spatial Mixer's Distance Model.
        let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(
            cullDistance: project.cullDistance
        )
        distanceModelParameters.rolloffFactor = project.rolloffFactor
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters

        // start head tracking
        hmm.startDeviceMotionUpdates(
            to: OperationQueue.current!,
            withHandler: { motion, error in
                guard let motion = motion, error == nil else { return }
                let m = motion.attitude.rotationMatrix
                let c = self.listener.transform
                // swift-format-ignore
                let headphoneTransform = simd_float4x4(
                    Float(m.m11), Float(m.m12), Float(m.m13), c.columns.3.x,
                    Float(m.m21), Float(m.m22), Float(m.m23), c.columns.3.y,
                    Float(m.m31), Float(m.m32), Float(m.m33), c.columns.3.z,
                    Float(0),     Float(0),     Float(0),     Float(1)
                )
                self.listener.transform = headphoneTransform
            }
        )

        // probably should handle these results
        project.soundEventAssets.forEach {
            _ = registerSoundEventAsset(soundEventAsset: $0)
        }
        project.soundEvents.forEach {
            if case .success(let phaseSoundEvent) = registerSoundEvent(soundEvent: $0) {
                phaseSoundEvent.start()
            }
        }

        return Result { try engine.start() }
    }

    func unloadProject(project: PhasorProject) {
        project.soundEvents.forEach {
            engine.assetRegistry.unregisterAsset(identifier: $0.id.uuidString)
        }
        project.soundEventAssets.forEach {
            engine.assetRegistry.unregisterAsset(identifier: $0.id.uuidString)
        }

        engine.stop()
    }
}
