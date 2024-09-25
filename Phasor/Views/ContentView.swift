//
//  ContentView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 9/13/24.
//

import SwiftUI
import PHASE

class PhasePlayer: ObservableObject {
    let engine = PHASEEngine(updateMode: .automatic)
    init() {
        // Retrieve the URL to an Audio File stored in our Application Bundle.
        let audioFileUrl = Bundle.main.url(forResource: "drums", withExtension: "wav")!
        
        // Register the Audio File at the URL.
        // Name it "drums", load it into resident memory and apply dynamic normalization to prepare it for playback.
        let soundAsset = try! engine.assetRegistry.registerSoundAsset(url: audioFileUrl,
                                                                     identifier: "drums",
                                                                     assetType: .resident,
                                                                     channelLayout: nil,
                                                                     normalizationMode: .dynamic)
        
        // Create a Spatial Pipeline.
        let spatialPipelineOptions: PHASESpatialPipeline.Flags = [.directPathTransmission, .lateReverb]
        let spatialPipeline = PHASESpatialPipeline(flags: spatialPipelineOptions)!
        spatialPipeline.entries[PHASESpatialCategory.lateReverb]!.sendLevel = 0.1;
        engine.defaultReverbPreset = .mediumRoom

        // Create a Spatial Mixer with the Spatial Pipeline.
        let spatialMixerDefinition = PHASESpatialMixerDefinition(spatialPipeline: spatialPipeline)

        // Set the Spatial Mixer's Distance Model.
        let distanceModelParameters = PHASEGeometricSpreadingDistanceModelParameters()
        distanceModelParameters.fadeOutParameters = PHASEDistanceModelFadeOutParameters(cullDistance: 10.0)
        distanceModelParameters.rolloffFactor = 1
        spatialMixerDefinition.distanceModelParameters = distanceModelParameters

        // Create a Sampler Node from "drums" and hook it into the downstream Spatial Mixer.
        let samplerNodeDefinition = PHASESamplerNodeDefinition(soundAssetIdentifier: "drums", mixerDefinition:spatialMixerDefinition)

        // Set the Sampler Node's Playback Mode to Looping.
        samplerNodeDefinition.playbackMode = .looping

        // Set the Sampler Node's Calibration Mode to Relative SPL and Level to 12 dB.
        samplerNodeDefinition.setCalibrationMode(calibrationMode: .relativeSpl, level: 0)

        // Set the Sampler Node's Cull Option to Sleep.
        samplerNodeDefinition.cullOption = .sleepWakeAtRealtimeOffset;

        // Register a Sound Event Asset with the Engine named "drumEvent".
        let soundEventAsset = try! engine.assetRegistry.registerSoundEventAsset(rootNode: samplerNodeDefinition, identifier: "drumsEvent")
        
        
        // Create a Listener.
        let listener = PHASEListener(engine: engine)

        // Set the Listener's transform to the origin with no rotation.
        listener.transform = matrix_identity_float4x4;

        // Attach the Listener to the Engine's Scene Graph via its Root Object.
        // This actives the Listener within the simulation.
        try! engine.rootObject.addChild(listener)
        
        // Create an Icosahedron Mesh.
        let mesh = MDLMesh.newIcosahedron(withRadius: 0.0142, inwardNormals: false, allocator:nil)

        // Create a Shape from the Icosahedron Mesh.
        let shape = PHASEShape(engine: engine, mesh: mesh)

        // Create a Volumetric Source from the Shape.
        let source = PHASESource(engine: engine, shapes: [shape])

        // Translate the Source 2 meters in front of the Listener
        var sourceTransform = simd_float4x4()
        sourceTransform.columns.0 = simd_make_float4(1.0, 0.0, 0.0, 0.0)
        sourceTransform.columns.1 = simd_make_float4(0.0, 1.0, 0.0, 0.0)
        sourceTransform.columns.2 = simd_make_float4(0.0, 0.0, 1.0, 0.0)
        sourceTransform.columns.3 = simd_make_float4(0.0, 0.0, 2.0, 1.0)
        source.transform = sourceTransform;

        // Attach the Source to the Engine's Scene Graph.
        // This actives the Listener within the simulation.
        try! engine.rootObject.addChild(source)
        
        // Associate the Source and Listener with the Spatial Mixer in the Sound Event.
        let mixerParameters = PHASEMixerParameters()
        mixerParameters.addSpatialMixerParameters(identifier: spatialMixerDefinition.identifier, source: source, listener: listener)

        // Create a Sound Event from the built Sound Event Asset "drumEvent".
        let soundEvent = try! PHASESoundEvent(engine: engine, assetIdentifier: "drumsEvent", mixerParameters: mixerParameters)
        
        try! engine.start()
        soundEvent.start()
    }
}

struct ContentView: View {
    @StateObject var player = PhasePlayer()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

