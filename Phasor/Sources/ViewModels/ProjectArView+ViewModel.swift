//
//  ProjectArView+ViewModel.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/13/25.
//

import ARKit
import Foundation
import PHASE
import RealityKit
import SwiftData
import SwiftUI

extension ProjectArView {
    @Observable
    class ViewModel {
        private var project: PhasorProject
        private var player: PhasePlayer
        var delegate: ProjectArDelegate

        var errorMessageComponent: ErrorMessageComponent
        var modelContextComponent: ModelContextComponent

        init(project: PhasorProject) {
            let player = PhasePlayer(project: project)
            let delegate = ProjectArDelegate(player: player)
            let errorMessageComponent = ErrorMessageComponent()
            let modelContextComponent = ModelContextComponent(
                errorMessageComponent: errorMessageComponent
            )

            self.project = project
            self.player = player
            self.delegate = delegate
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
        }

        func placeSoundSource(playing soundEventAsset: SoundEventAsset) {
            let position = delegate.placeOrb()

            var transform = simd_float4x4(1)
            transform.columns.3.x = position.x
            transform.columns.3.y = position.y
            transform.columns.3.z = position.z

            let playbackSource = PlaybackSource(transform: transform)
            let soundEvent = SoundEvent(
                soundEventAsset: soundEventAsset,
                playbackSource: playbackSource
            )
            let result = player.registerSoundEvent(soundEvent: soundEvent)

            switch result {
            case .success():
                player.soundEventMap[soundEvent]?.start()
            case .failure(_):
                errorMessageComponent.message = "Couldn't place sound source."
                errorMessageComponent.isPresented = true
            }

        }
    }
}
