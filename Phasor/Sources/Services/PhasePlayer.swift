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

//func simd_float4x4(
//    _ a0: Float, _ a1: Float, _ a2: Float, _ a3: Float,
//    _ b0: Float, _ b1: Float, _ b2: Float, _ b3: Float,
//    _ c0: Float, _ c1: Float, _ c2: Float, _ c3: Float,
//    _ d0: Float, _ d1: Float, _ d2: Float, _ d3: Float
//) -> simd_float4x4 {
//    return simd_float4x4(rows: [
//        SIMD4<Float>(a0, a1, a2, a3),
//        SIMD4<Float>(b0, b1, b2, b3),
//        SIMD4<Float>(c0, c1, c2, c3),
//        SIMD4<Float>(d0, d1, d2, d3),
//    ])
//}

class PhasePlayer: ObservableObject {
    private let engine = PHASEEngine(updateMode: .automatic)
    private let hmm = CMHeadphoneMotionManager()
    private let listener: PHASEListener
    private let spatialMixerDefinition: PHASESpatialMixerDefinition
    private let spatialPipeline: PHASESpatialPipeline
    private let distanceModelParameters: PHASEGeometricSpreadingDistanceModelParameters

    func registerSoundAsset(_ soundAsset: SoundAsset) throws {
        // the overload that uses Data just gives me EXC_BAD_ACCESS every time
        // workaround for now is to write to a file and read it
        let tempUrl = URL.documentsDirectory.appending(path: soundAsset.id.uuidString)
        try soundAsset.data.write(to: tempUrl)
        try engine.assetRegistry
            .registerSoundAsset(
                url: tempUrl,
                identifier: soundAsset.id.uuidString,
                // this must be resident to load everything into memory
                assetType: .resident,
                // todo: need to store channel layout
                channelLayout: nil,
                normalizationMode: .dynamic
            )
        // need to delete the temp file after finished
        // todo: will deleting immediately before playing break it?
        // try FileManager.default.removeItem(at: tempUrl)
    }

    func unregisterSoundAsset(_ soundAsset: SoundAsset) {
        engine.assetRegistry
            .unregisterAsset(identifier: soundAsset.id.uuidString)
    }

    func registerPlaybackSource(_ playbackSource: PlaybackSource) throws -> PHASESource {
        let phaseSource = PHASESource(engine: engine)

        phaseSource.transform = playbackSource.transform

        try engine.rootObject.addChild(phaseSource)

        return phaseSource
    }

    func registerSoundEvent(soundEvent: SoundEvent, source: PHASESource) throws -> PHASESoundEvent {
        let phaseMixerParameters = PHASEMixerParameters()
        phaseMixerParameters
            .addSpatialMixerParameters(
                identifier: spatialMixerDefinition.identifier,
                source: source,
                listener: listener
            )

        return try PHASESoundEvent(
            engine: engine,
            assetIdentifier: soundEvent.id.uuidString,
            mixerParameters: phaseMixerParameters
        )
    }

    func registerSoundEventAsset(soundEventAsset: SoundEventAsset) throws {
        let samplerNodeDefinition = PHASESamplerNodeDefinition(
            soundAssetIdentifier: soundEventAsset.id.uuidString,
            mixerDefinition: spatialMixerDefinition
        )

        samplerNodeDefinition.playbackMode = soundEventAsset.playbackMode
        samplerNodeDefinition.setCalibrationMode(
            calibrationMode: .relativeSpl,
            level: soundEventAsset.calibrationLevel
        )
        samplerNodeDefinition.cullOption = soundEventAsset.cullOption

        try engine.assetRegistry.registerSoundEventAsset(
            rootNode: samplerNodeDefinition,
            identifier: soundEventAsset.id.uuidString
        )
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

        // Set the Spatial Mixer's Distance Model.
        distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
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
    }

    func loadProject(project: PhasorProject) throws {
        engine.defaultReverbPreset = project.reverbPreset
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(
            cullDistance: project.cullDistance
        )
        distanceModelParameters.rolloffFactor = project.rolloffFactor

        let phasePlaybackSources = try project.playbackSources.map {
            try registerPlaybackSource($0)
        }
        try project.soundEventAssets
            .flatMap(\.soundAssets)
            .forEach { try registerSoundAsset($0) }
        try project.soundEventAssets.forEach { try registerSoundEventAsset(soundEventAsset: $0) }

        for (soundEvent, phasePlaybackSource) in zip(
            project.soundEvents,
            phasePlaybackSources
        ) {
            let phaseSoundEvent = try registerSoundEvent(
                soundEvent: soundEvent,
                source: phasePlaybackSource
            )
            phaseSoundEvent.start()
        }
    }

    func updateTransform(with newTransform: simd_float4x4) {
        listener.transform = newTransform
    }

    func headTrackingSupported() -> Bool {
        return hmm.isDeviceMotionAvailable
    }

    deinit {
        hmm.stopDeviceMotionUpdates()
    }
}
