//
//  ProjectArDelegate.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/13/25.
//

import ARKit
import Foundation
import PHASE
import RealityKit
import SwiftUI

@Observable
class ProjectArDelegate: NSObject, ARSessionDelegate {
    var distance: Double = 1.0

    var arView: ARView!
    var latestTransform: simd_float4x4?
    var player: PhasePlayer

    init(
        distance: Double = 1.0,
        arView: ARView! = nil,
        latestTransform: simd_float4x4? = nil,
        player: PhasePlayer
    ) {
        self.distance = distance
        self.arView = arView
        self.latestTransform = latestTransform
        self.player = player
    }

    private func getPosition(forwards distance: Double, from transform: Transform) -> SIMD3<Float> {
        let direction = transform.matrix.columns.2
        let position = transform.translation
        let newPosition =
            position - SIMD3(x: direction.x, y: direction.y, z: direction.z)
            * SIMD3(repeating: Float(distance))
        return newPosition
    }

    // this function has access to ARKit and can be called from SwiftUI
    func placeOrb(at inputTransform: Transform? = nil) -> SIMD3<Float> {
        let transform = inputTransform ?? arView.cameraTransform
        let position = getPosition(forwards: distance, from: transform)

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
