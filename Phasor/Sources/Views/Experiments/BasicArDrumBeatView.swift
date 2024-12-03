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
        let delegate = BasicArDrumBeatSessionDelegate(player: player)
        
        let arViewRepresentable = BasicArDrumBeatViewRepresentable(delegate: delegate)
                
        arViewRepresentable
            .edgesIgnoringSafeArea(.all) // Makes ARView fill the entire screen
            .onAppear() {
                try! initPlayerSources()
                
                let soundEvent = try! player.createSoundEvent(source: soundSource, soundEventAssetIdentifier: drumsSoundEventIdentifier)
                
                soundEvent.start()
            }
            .onDisappear() {
                deinitPlayerSources()
            }
    }
    
    @State var soundSource: PHASESource!
    @EnvironmentObject var player: PhasePlayerFromUrl
    
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
        
        // swift-format-ignore
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


struct BasicArDrumBeatViewRepresentable: UIViewRepresentable {
    let delegate: BasicArDrumBeatSessionDelegate
    
    init(delegate: BasicArDrumBeatSessionDelegate) {
        self.delegate = delegate
    }
    
    func makeUIView(context: Context) -> some UIView {
        let arView = BasicArDrumBeatARView()
        
        arView.session.delegate = delegate
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}


class BasicArDrumBeatSessionDelegate: NSObject, ARSessionDelegate {
    let player: PhasePlayerFromUrl
    
    init(player: PhasePlayerFromUrl) {
        self.player = player
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let transform =  session.currentFrame?.camera.transform else { return }
        player.listener.transform = transform
    }
}


class BasicArDrumBeatARView : ARView {
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    dynamic required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        
        placeOrb()
    }
    
    func placeOrb() {
        let sphere = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let orb = ModelEntity(mesh: sphere, materials: [material])
        
        let anchor = AnchorEntity(world: .init(x: 2.0, y: 0.0, z: 0.0))
        anchor.addChild(orb)

        scene.addAnchor(anchor)
    }
}


#Preview {
    BasicArDrumBeatView()
        .environmentObject(PhasePlayerFromUrl())
}
