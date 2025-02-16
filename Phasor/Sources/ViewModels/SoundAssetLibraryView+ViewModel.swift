//
//  SoundAssetLibraryView+ViewModel.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import AVFoundation
import Foundation
import SwiftData
import SwiftUI

extension SoundAssetLibraryView {
    @Observable
    public class ViewModel {
        // it is up to our view to pass this back to us
        var modelContext: ModelContext! = nil {
            didSet {
                modelContextComponent.modelContext = modelContext
            }
        }

        public var fileImporterIsPresented: Bool = false

        public var errorMessageComponent: ErrorMessageComponent
        public var modelContextComponent: ModelContextComponent
        public var deleteConfirmationComponent: DeleteConfirmationComponent<SoundAsset>
        public var renameModalComponent: RenameModalComponent<SoundAsset>
        public var fileImporterComponent: FileImporterComponent

        init() {
            // construct dependency graph
            let errorMessageComponent = ErrorMessageComponent()
            let modelContextComponent = ModelContextComponent(
                errorMessageComponent: errorMessageComponent
            )
            let deleteConfirmationComponent = DeleteConfirmationComponent<SoundAsset>(
                confirmationText: { soundAsset in
                    if soundAsset.associatedSoundEventAssets.isEmpty {
                        return "Are you sure you want to delete \(soundAsset.name)?"
                    } else {
                        return
                            "Are you sure you want to delete \(soundAsset.name)? Its associated sound events will be deleted."
                    }
                },
                namePath: \SoundAsset.name,
                modelContextComponent: modelContextComponent
            )
            let renameModalComponent = RenameModalComponent(
                namePath: \SoundAsset.name,
                modelContextComponent: modelContextComponent
            )
            let fileImporterComponent = FileImporterComponent(
                modelContextComponent: modelContextComponent,
                errorMessageComponent: errorMessageComponent
            )

            // assign all at once
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
            self.deleteConfirmationComponent = deleteConfirmationComponent
            self.renameModalComponent = renameModalComponent
            self.fileImporterComponent = fileImporterComponent
        }

        public var audioPlayer: AudioPlayer = AudioPlayer()

        public func newItem() {
            fileImporterIsPresented = true
        }

        public func importFile(url: URL) {
            guard let soundAsset = fileImporterComponent.importFile(url: url, name: nil) else {
                return
            }
            modelContextComponent.modelContext.insert(soundAsset)
            _ = modelContextComponent.trySaveModelContext(withMessage: "Something went wrong.")
        }

        public func tapAsset(asset: SoundAsset) {
            do {
                try audioPlayer.handleAsset(asset: asset)
            } catch {
                errorMessageComponent.message = "Something went wrong playing \(asset.name)."
                errorMessageComponent.isPresented = true
            }
        }

        public func onDisapper() {
            audioPlayer.stop()
        }
    }
}
