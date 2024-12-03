//
//  ArPlaceObjectsView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 10/22/24.
//

import SwiftUI
import RealityKit
import ARKit
import PHASE

fileprivate let tracks = [
    "espresso_backings",
    "espresso_bass",
    "espresso_drums",
    "espresso_guitar_others",
    "espresso_vocal",
    "drums",
]

fileprivate func getSoundIdentifier(for track: String) -> String {
    return "arplaceobjectsview-\(track)"
}

fileprivate func getSoundEventIdentifier(for track: String) -> String {
    return "arplaceobjectsview-\(track)Event"
}


struct ArPlaceObjectsView: View {
    @StateObject var arViewDelegate = ArPlaceObjectsDelegate()
    @EnvironmentObject var player: PhasePlayerFromUrl
    
    var body: some View {
        ZStack {
            ArPlaceObjectsViewRepresentable(delegate: arViewDelegate)
                .edgesIgnoringSafeArea(.all) // Makes ARView fill the entire screen
            VStack {
                Spacer()
                Slider(
                    value: $arViewDelegate.distance,
                    in: 0.0...3.0
                )
                Menu() {
                    Button("Drums") {
                        placeSoundSource(
                            playing: getSoundEventIdentifier(for: "drums")
                        )
                    }
                    Button("Espresso Backings") {
                        placeSoundSource(
                            playing: getSoundEventIdentifier(for: "espresso_backings")
                        )
                    }
                    Button("Espresso Bass") {
                        placeSoundSource(
                            playing: getSoundEventIdentifier(for: "espresso_bass")
                        )
                    }
                    Button("Espresso Drums") {
                        placeSoundSource(
                            playing: getSoundEventIdentifier(for: "espresso_drums")
                        )
                    }
                    Button("Espresso Guitar and others") {
                        placeSoundSource(
                            playing: getSoundEventIdentifier(for: "espresso_guitar_others")
                        )
                    }
                    Button("Espresso Vocals") {
                        placeSoundSource(
                            playing: getSoundEventIdentifier(for: "espresso_vocal")
                        )
                    }
                } label: {
                    Image(systemName: "plus.viewfinder")
                        .font(.custom("SF", size: 100.0, relativeTo: .title))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.primary, Color.accentColor)
                }
            }
            .padding()
        }
        .onAppear {
            try! initPlayerSources()
            arViewDelegate.player = player
        }
        .onDisappear {
            deinitPlayerSources()
        }
    }
    
    private func placeSoundSource(playing soundEventAssetIdentifier: String) {
        let position = arViewDelegate.placeOrb()
        
        var transform = simd_float4x4(1)
        transform.columns.3.x = position.x
        transform.columns.3.y = position.y
        transform.columns.3.z = position.z
        
        let soundSource = try! player.createPlaybackSource(
            transform: transform
        )
        
        let soundEvent = try! player.createSoundEvent(
            source: soundSource,
            soundEventAssetIdentifier: soundEventAssetIdentifier
        )
        
        soundEvent.start()
    }
    
    
    private func initPlayerSources() throws {
        for track in tracks {
            // Retrieve the URL to an Audio File stored in our Application Bundle.
            let audioFileUrl = Bundle.main.url(
                forResource: track,
                withExtension: "wav"
            )!
            
            // Register the Audio File at the URL.
            try player.addSoundAsset(
                url: audioFileUrl,
                identifier: getSoundIdentifier(for: track)
            )
            
            try player.createSoundEventAsset(
                soundEventAssetIdentifier: getSoundEventIdentifier(for: track),
                soundAssetIdentifier: getSoundIdentifier(for: track),
                playbackMode: .looping,
                calibrationLevel: 0.0,
                cullOption: .sleepWakeAtRealtimeOffset
            )
        }
        try! player.engine.start()
    }
    
    private func deinitPlayerSources() {
        for track in tracks {
            player.removeAsset(identifier: getSoundIdentifier(for: track))
            player.removeAsset(identifier: getSoundEventIdentifier(for: track))
        }
    }
}

// UIViewRepresentable creates and has direct access to ARView
// Also is the SwiftUI element with the camera feed for AR
struct ArPlaceObjectsViewRepresentable: UIViewRepresentable {
    // Not sure why this has to be @ObservedObject and not just regular property
    // Setting the delegate's arView property is connects SwiftUI and ARKit
    @ObservedObject var delegate: ArPlaceObjectsDelegate
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ArPlaceObjectsARView()
        
        let coachingOverlay = ARCoachingOverlayView()
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = arView.session
        
        arView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arView.heightAnchor)
        ])
        
        delegate.arView = arView
        arView.session.delegate = delegate
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

// Has to extend ObservableObject to let the view use @StateObject on it
// arView has to be nullable since it is assigned to it after
// maybe can make it ARView! since I'm sure it's assigned before hand?
class ArPlaceObjectsDelegate : NSObject, ObservableObject, ARSessionDelegate {
    @Published var distance: Double = 1.0
    
    var arView: ARView!
    var latestTransform: simd_float4x4?
    var player: PhasePlayerFromUrl!
    
    private func getPosition(forwards distance: Double, from transform: Transform) -> SIMD3<Float> {
        let direction = transform.matrix.columns.2
        let position = transform.translation
        let newPosition = position - SIMD3(x: direction.x, y: direction.y, z: direction.z) * SIMD3(repeating: Float(distance))
        return newPosition
    }
    
    // this function has access to ARKit and can be called from SwiftUI
    func placeOrb() -> SIMD3<Float> {
        let cameraTransform = arView.cameraTransform
        let position = getPosition(forwards: distance, from: cameraTransform)
        
        let sphere = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let orb = ModelEntity(mesh: sphere, materials: [material])
        
        let anchor = AnchorEntity(world: position)
        anchor.addChild(orb)
        
        arView.scene.addAnchor(anchor)
        return position
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let transform = session.currentFrame?.camera.transform {
            player.listener.transform = transform
        }
    }
}

// Custom ARView not required, this is just a sample class
class ArPlaceObjectsARView : ARView, ARSessionDelegate {
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    dynamic required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.session.delegate = self
    }
}

#Preview {
    ArPlaceObjectsView()
        .environmentObject(PhasePlayerFromUrl())
}
