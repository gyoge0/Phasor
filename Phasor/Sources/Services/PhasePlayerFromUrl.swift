//
//  PhasePlayer.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 10/2/24.
//


import SwiftUI
import PHASE
import CoreMotion

// swift-format-ignore
func simd_float4x4(
    _ a0: Float, _ a1: Float, _ a2: Float, _ a3: Float,
    _ b0: Float, _ b1: Float, _ b2: Float, _ b3: Float,
    _ c0: Float, _ c1: Float, _ c2: Float, _ c3: Float,
    _ d0: Float, _ d1: Float, _ d2: Float, _ d3: Float
) -> simd_float4x4 {
    return simd_float4x4(rows: [
        SIMD4<Float>(a0, a1, a2, a3),
        SIMD4<Float>(b0, b1, b2, b3),
        SIMD4<Float>(c0, c1, c2, c3),
        SIMD4<Float>(d0, d1, d2, d3),
    ])
}

class PhasePlayerFromUrl: ObservableObject {
    let engine = PHASEEngine(updateMode: .automatic)
    let hmm = CMHeadphoneMotionManager()
    let listener : PHASEListener;
    let spatialMixerDefinition: PHASESpatialMixerDefinition;
    let spatialPipeline: PHASESpatialPipeline;
    
    
    func addSoundAsset(url: URL, identifier: String) throws {
        try engine.assetRegistry.registerSoundAsset(
            url: url,
            identifier: identifier,
            assetType: .resident,
            channelLayout: nil,
            normalizationMode: .dynamic
        )
    }
    
    func removeAsset(identifier: String) {
        engine.assetRegistry.unregisterAsset(identifier: identifier)
    }
        
    
    func createPlaybackSource(transform: simd_float4x4) throws -> PHASESource {
        let source = PHASESource(engine: engine)
        
        source.transform = transform;
        
        // Attach the Source to the Engine's Scene Graph.
        // This actives the Listener within the simulation.
        try engine.rootObject.addChild(source)
        
        return source;
    }
    
    
    func createSoundEvent(source: PHASESource, soundEventAssetIdentifier: String) throws -> PHASESoundEvent  {
        // Associate the Source and Listener with the Spatial Mixer in the Sound Event.
        let mixerParameters = PHASEMixerParameters()
        mixerParameters.addSpatialMixerParameters(identifier: spatialMixerDefinition.identifier, source: source, listener: listener)
        
        // Create a Sound Event from the built Sound Event Asset "drumEvent".
        let soundEvent = try PHASESoundEvent(engine: engine, assetIdentifier: soundEventAssetIdentifier, mixerParameters: mixerParameters)
        
        return soundEvent;
    }
    
    
    func createSoundEventAsset(
        soundEventAssetIdentifier: String,
        soundAssetIdentifier: String,
        playbackMode: PHASEPlaybackMode,
        calibrationLevel: Double,
        cullOption: PHASECullOption
    ) throws {
        // Create a Sampler Node from "drums" and hook it into the downstream Spatial Mixer.
        let samplerNodeDefinition = PHASESamplerNodeDefinition(soundAssetIdentifier: soundAssetIdentifier, mixerDefinition:spatialMixerDefinition)
        
        // Set the Sampler Node's Playback Mode to Looping.
        samplerNodeDefinition.playbackMode = playbackMode
        
        // Set the Sampler Node's Calibration Mode to Relative SPL and Level to 12 dB.
        samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: calibrationLevel)
        
        // Set the Sampler Node's Cull Option to Sleep.
        samplerNodeDefinition.cullOption = cullOption;
        // Register a Sound Event Asset with the Engine named "drumEvent".
        try engine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: soundEventAssetIdentifier)
    }
    
    
    init() {
        self.listener = PHASEListener(engine: engine)
        // Set the Listener's transform to the origin with no rotation.
        self.listener.transform = matrix_identity_float4x4;
        
        // Attach the Listener to the Engine's Scene Graph via its Root Object.
        // This actives the Listener within the simulation.
        try! engine.rootObject.addChild(self.listener)
        
        // Create a Spatial Pipeline.
        let spatialPipelineOptions: PHASESpatialPipeline.Flags = [.directPathTransmission, .lateReverb]
        self.spatialPipeline = PHASESpatialPipeline(flags: spatialPipelineOptions)!
        self.spatialPipeline.entries[PHASESpatialCategory.lateReverb]!.sendLevel = 0.1;
        engine.defaultReverbPreset = .mediumRoom
        
        // Create a Spatial Mixer with the Spatial Pipeline.
        self.spatialMixerDefinition = PHASESpatialMixerDefinition(spatialPipeline: self.spatialPipeline)
        
        // Set the Spatial Mixer's Distance Model.
        let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(cullDistance: 1.0)
        distanceModelParameters.rolloffFactor = 1
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters
        
        // start head tracking
        hmm.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {motion, error  in
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
        })
    }

    
    deinit {
        hmm.stopDeviceMotionUpdates()
    }
}
