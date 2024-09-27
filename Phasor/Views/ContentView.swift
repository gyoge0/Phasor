//
//  ContentView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 9/13/24.
//

import SwiftUI
import PHASE

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


class PhasePlayer: ObservableObject {
    let engine = PHASEEngine(updateMode: .automatic)
    let listener : PHASEListener;
    let spatialMixerDefinition: PHASESpatialMixerDefinition;
    let spatialPipeline: PHASESpatialPipeline;
    
    
    func addSoundAsset(url: URL, identifier: String) {
        try! engine.assetRegistry.registerSoundAsset(
            url: url,
            identifier: identifier,
            assetType: .resident,
            channelLayout: nil,
            normalizationMode: .dynamic
        )
    }
    
    
    func createPlaybackSource(transform: simd_float4x4) -> PHASESource {
        let source = PHASESource(engine: engine)
        
        source.transform = transform;
        
        // Attach the Source to the Engine's Scene Graph.
        // This actives the Listener within the simulation.
        try! engine.rootObject.addChild(source)
        
        return source;
    }
    
    
    func createSoundEvent(source: PHASESource, assetIdentifier: String) -> PHASESoundEvent {
        // Associate the Source and Listener with the Spatial Mixer in the Sound Event.
        let mixerParameters = PHASEMixerParameters()
        mixerParameters.addSpatialMixerParameters(identifier: spatialMixerDefinition.identifier, source: source, listener: listener)
        
        // Create a Sound Event from the built Sound Event Asset "drumEvent".
        let soundEvent = try! PHASESoundEvent(engine: engine, assetIdentifier: assetIdentifier, mixerParameters: mixerParameters)
        
        return soundEvent;
    }
    
    
    func createSoundEventAsset(
        soundEventAssetIdentifier: String,
        soundAssetIdentifier: String,
        playbackMode: PHASEPlaybackMode,
        calibrationLevel: Double,
        cullOption: PHASECullOption
    ) {
        // Create a Sampler Node from "drums" and hook it into the downstream Spatial Mixer.
        let samplerNodeDefinition = PHASESamplerNodeDefinition(soundAssetIdentifier: soundAssetIdentifier, mixerDefinition:spatialMixerDefinition)
        
        // Set the Sampler Node's Playback Mode to Looping.
        samplerNodeDefinition.playbackMode = playbackMode
        
        // Set the Sampler Node's Calibration Mode to Relative SPL and Level to 12 dB.
        samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: calibrationLevel)
        
        // Set the Sampler Node's Cull Option to Sleep.
        samplerNodeDefinition.cullOption = cullOption;
        
        // Register a Sound Event Asset with the Engine named "drumEvent".
        try! engine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: soundEventAssetIdentifier)
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
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(cullDistance: 10.0)
        distanceModelParameters.rolloffFactor = 1
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters
    }
}


struct ContentView: View {
    @StateObject var player = PhasePlayer()
    @State var leftSource: PHASESource!
    @State var rightSource: PHASESource!
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button(action: { playSound(source: rightSource) }) {
                Text("Play Sound Right")
            }
            Button(action: { playSound(source: leftSource) }) {
                Text("Play Sound Left")
            }
        }
        .padding()
        .onAppear(perform: initOnAppear)
    }

    
    private func initOnAppear() {
        // Retrieve the URL to an Audio File stored in our Application Bundle.
        let audioFileUrl = Bundle.main.url(forResource: "drums", withExtension: "wav")!
        
        // Register the Audio File at the URL.
        player.addSoundAsset(url: audioFileUrl, identifier: "drums")
        
        player.createSoundEventAsset(
            soundEventAssetIdentifier: "drumsEvent",
            soundAssetIdentifier: "drums",
            playbackMode: .oneShot,
            calibrationLevel: 0.0,
            cullOption: .sleepWakeAtRealtimeOffset
        )
        
        leftSource = player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, -2.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        rightSource = player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, 2.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        try! player.engine.start()
    }
    
    
    func playSound(source: PHASESource) {
        let soundEvent = player.createSoundEvent(source: source, assetIdentifier: "drumsEvent")
        
        
        soundEvent.start()
    }
}

