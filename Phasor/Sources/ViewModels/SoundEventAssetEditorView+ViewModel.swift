//
//  SoundEventAssetEditorView+ViewModel.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import AVFoundation
import Foundation
import PHASE
import SwiftData
import SwiftUI

extension SoundEventAssetEditorView {
    @Observable
    class ViewModel {
        // it is up to our view to pass these back to us
        var soundEventAsset: SoundEventAsset! = nil

        public var errorMessageComponent: ErrorMessageComponent
        public var modelContextComponent: ModelContextComponent
        public var deleteConfirmationComponent: DeleteConfirmationComponent<SoundEventAsset>
        public var renameModalComponent: RenameModalComponent<SoundEventAsset>

        init() {
            // construct dependency graph
            let errorMessageComponent = ErrorMessageComponent()
            let modelContextComponent = ModelContextComponent(
                errorMessageComponent: errorMessageComponent
            )
            let deleteConfirmationComponent = DeleteConfirmationComponent(
                namePath: \SoundEventAsset.name,
                modelContextComponent: modelContextComponent
            )
            let renameModalComponent = RenameModalComponent(
                namePath: \SoundEventAsset.name,
                modelContextComponent: modelContextComponent
            )

            // assign all at once
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
            self.deleteConfirmationComponent = deleteConfirmationComponent
            self.renameModalComponent = renameModalComponent
        }

        public var audioPlayer = AudioPlayer()
        var playbackState: PlaybackState = .stopped

        func handleAsset(soundAsset: SoundAsset) {
            do {
                try audioPlayer.handleAsset(asset: soundAsset)
                playbackState = audioPlayer.playbackState
            } catch {
                errorMessageComponent.message = "Something went wrong playing \(soundAsset.name)."
                errorMessageComponent.isPresented = true
            }
        }

        func onDisapper() {
            audioPlayer.stop()
        }

        func save(soundEventAsset: SoundEventAsset) -> Bool {
            modelContextComponent.modelContext.insert(soundEventAsset)
            return modelContextComponent.trySaveModelContext(
                withMessage: "Couldn't save \(soundEventAsset.name)"
            )
        }

    }
}
