//
//  ProjectArView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/12/24.
//

import ARKit
import PHASE
import RealityKit
import SwiftData
import SwiftUI

struct ProjectArView: View {
    @Binding var project: PhasorProject
    @Environment(\.modelContext) var modelContext: ModelContext

    @StateObject var arViewDelegate = ArPlaceObjectsDelegate()
    @StateObject var player = PhasePlayer()

    var body: some View {
        ZStack {
            ArPlaceObjectsViewRepresentable(delegate: arViewDelegate)
                .edgesIgnoringSafeArea(.all)  // Makes ARView fill the entire screen

            VStack {
                Spacer()
                Slider(
                    value: $arViewDelegate.distance,
                    in: 0.0...3.0
                )
                Menu {
                    ForEach($project.soundEventAssets, id: \.id) { $item in
                        Button(item.name) {
                            try! placeSoundSource(playing: item)
                        }
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
            try! player.loadProject(project: project)
            arViewDelegate.player = player
        }
    }

    static func checkTechnologiesSupported() -> Bool {
        return ARConfiguration.isSupported
    }

    private func placeSoundSource(playing soundEventAsset: SoundEventAsset) throws {
        let position = arViewDelegate.placeOrb()

        var transform = simd_float4x4(1)
        transform.columns.3.x = position.x
        transform.columns.3.y = position.y
        transform.columns.3.z = position.z

        let playbackSource = PlaybackSource(transform: transform)
        let soundEvent = SoundEvent(source: playbackSource, eventAsset: soundEventAsset)

        let phasePlaybackSource = try player.registerPlaybackSource(playbackSource)
        let phaseSoundEvent = try player.registerSoundEvent(
            soundEvent: soundEvent,
            source: phasePlaybackSource
        )

        phaseSoundEvent.start()
    }
}

// UIViewRepresentable creates and has direct access to ARView
// Also is the SwiftUI element with the camera feed for AR
struct ArPlaceObjectsViewRepresentable: UIViewRepresentable {
    // Not sure why this has to be @ObservedObject and not just regular property
    // Setting the delegate's arView property connects SwiftUI and ARKit
    @ObservedObject var delegate: ArPlaceObjectsDelegate

    func makeUIView(context: Context) -> some UIView {
        let arView = ArPlaceObjectsARView()

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
class ArPlaceObjectsDelegate: NSObject, ObservableObject, ARSessionDelegate {
    @Published var distance: Double = 1.0

    var arView: ARView!
    var latestTransform: simd_float4x4?
    var player: PhasePlayer!

    private func getPosition(forwards distance: Double, from transform: Transform) -> SIMD3<Float> {
        let direction = transform.matrix.columns.2
        let position = transform.translation
        let newPosition =
            position - SIMD3(x: direction.x, y: direction.y, z: direction.z)
            * SIMD3(repeating: Float(distance))
        return newPosition
    }

    // this function has access to ARKit and can be called from SwiftUI
    func placeOrb() -> SIMD3<Float> {
        let cameraTransform = arView.cameraTransform
        let position = getPosition(forwards: distance, from: cameraTransform)

        let sphere = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let orb = ModelEntity(mesh: sphere, materials: [material])

        place(orb, at: position)
        return position
    }

    func place(_ modelEntity: ModelEntity, at position: SIMD3<Float>) {
        let anchor = AnchorEntity(world: position)
        anchor.addChild(modelEntity)

        arView.scene.addAnchor(anchor)
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let newTransform = session.currentFrame?.camera.transform {
            player.updateTransform(with: newTransform)
        }
    }
}

// Custom ARView not required, this is just a sample class
class ArPlaceObjectsARView: ARView, ARSessionDelegate {
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
