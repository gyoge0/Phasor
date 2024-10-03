//
//  BasicArDrumBeatView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 10/3/24.
//

import SwiftUI
import RealityKit
import ARKit
import PHASE

fileprivate let drumsSoundIdentifier = "basicardrumbeatview-drums"
fileprivate let drumsSoundEventIdentifier = "basicardrumbeatview-drumsEvent"

struct BasicArDrumBeatView: View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all) // Makes ARView fill the entire screen
            .onAppear() {
                try! initPlayerSources()
                
                let soundEvent = try! player.createSoundEvent(source: soundSource, soundeEventAssetIdentifier: drumsSoundEventIdentifier)
                
                soundEvent.start()
            }
            .onDisappear() {
                deinitPlayerSources()
            }
    }
    
    @State var soundSource: PHASESource!
    @EnvironmentObject var player: PhasePlayer
    
    private func initPlayerSources() throws {
        // Retrieve the URL to an Audio File stored in our Application Bundle.
        let audioFileUrl = Bundle.main.url(forResource: "drums", withExtension: "wav")!
        
        // Register the Audio File at the URL.
        try player.addSoundAsset(url: audioFileUrl, identifier: drumsSoundIdentifier)
        
        try player.createSoundEventAsset(
            soundEventAssetIdentifier: drumsSoundEventIdentifier,
            soundAssetIdentifier: drumsSoundIdentifier,
            playbackMode: .looping,
            calibrationLevel: 0.0,
            cullOption: .sleepWakeAtRealtimeOffset
        )
        
        soundSource = try player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, 2.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        try! player.engine.start()
    }
    
    private func deinitPlayerSources() {
        player.removeAsset(identifier: drumsSoundIdentifier)
        player.removeAsset(identifier: drumsSoundEventIdentifier)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.autoenablesDefaultLighting = true // Enables lighting for better visibility
        arView.delegate = context.coordinator
        
        // Set up the AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical] // Detect horizontal and vertical planes
        arView.session.run(configuration)
        
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        cubeNode.position = SCNVector3(2, 0, 0) // SceneKit/AR coordinates are in meters
        arView.scene.rootNode.addChildNode(cubeNode)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update the view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Get the current camera transform
            let cameraTransform = frame.camera.transform
            
            // Extract the position from the transform
            let cameraPosition = SCNVector3(
                cameraTransform.columns.3.x,
                cameraTransform.columns.3.y,
                cameraTransform.columns.3.z
            )
            
            // Report the camera's current position
            print(cameraPosition.x)
        }
        
    }
}


#Preview {
    BasicArDrumBeatView()
}
