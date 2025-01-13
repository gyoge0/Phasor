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

            // assign all at once
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
            self.deleteConfirmationComponent = deleteConfirmationComponent
            self.renameModalComponent = renameModalComponent
        }

        public var audioPlayer: AudioPlayer = AudioPlayer()

        public func newItem() {
            fileImporterIsPresented = true
        }

        public func importFile(url: URL) {
            guard url.startAccessingSecurityScopedResource() else {
                errorMessageComponent.message = "Something went wrong accessing the file."
                errorMessageComponent.isPresented = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            guard let data = try? Data(contentsOf: url) else {
                errorMessageComponent.message = "Something went wrong reading the file."
                errorMessageComponent.isPresented = true
                return
            }

            let soundAsset = SoundAsset(name: url.lastPathComponent, data: data)
            modelContext.insert(soundAsset)
            // should an error be shown?
            try? modelContext.save()
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
