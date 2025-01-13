//
//  ProjectEditorView+ViewModel.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import ARKit
import Foundation
import SwiftData
import SwiftUI

extension ProjectEditorView {
    @Observable
    class ViewModel {
        // it is up to our view to pass these back to us
        var modelContext: ModelContext! = nil {
            didSet {
                modelContextComponent.modelContext = modelContext
            }
        }

        var project: PhasorProject! = nil

        public var newSoundEventAssetPopoverIsPresented: Bool = false
        public var editingSoundEventAsset: SoundEventAsset? = nil

        public var errorMessageComponent: ErrorMessageComponent
        public var modelContextComponent: ModelContextComponent
        public var projectDeleteConfirmationComponent: DeleteConfirmationComponent<PhasorProject>
        public var soundEventAssetDeleteConfirmationComponent:
            DeleteConfirmationComponent<SoundEventAsset>
        public var projectRenameModalComponent: RenameModalComponent<PhasorProject>
        public var soundEventAssetRenameModalComponent: RenameModalComponent<SoundEventAsset>

        init() {
            // construct dependency graph
            let errorMessageComponent = ErrorMessageComponent()
            let modelContextComponent = ModelContextComponent(
                errorMessageComponent: errorMessageComponent
            )
            let projectDeleteConfirmationComponent = DeleteConfirmationComponent(
                namePath: \PhasorProject.name,
                modelContextComponent: modelContextComponent
            )
            let soundEventAssetDeleteConfirmationComponent = DeleteConfirmationComponent(
                namePath: \SoundEventAsset.name,
                modelContextComponent: modelContextComponent
            )
            let projectRenameModalComponent = RenameModalComponent(
                namePath: \PhasorProject.name,
                modelContextComponent: modelContextComponent
            )
            let soundEventAssetRenameModalComponent = RenameModalComponent(
                namePath: \SoundEventAsset.name,
                modelContextComponent: modelContextComponent
            )

            // assign all at once
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
            self.projectDeleteConfirmationComponent = projectDeleteConfirmationComponent
            self.soundEventAssetDeleteConfirmationComponent =
                soundEventAssetDeleteConfirmationComponent
            self.projectRenameModalComponent = projectRenameModalComponent
            self.soundEventAssetRenameModalComponent = soundEventAssetRenameModalComponent
        }

        public func newSoundEventAsset() {
            let newSoundEventAsset = SoundEventAsset()
            editingSoundEventAsset = newSoundEventAsset
            // show the popup before inserting model
            // otherwise you can see the ui change for a split second
            newSoundEventAssetPopoverIsPresented = true

            // we will insert now, and delete if cancelled
            modelContextComponent.modelContext.insert(newSoundEventAsset)
            _ = modelContextComponent.trySaveModelContext(withMessage: "Something went wrong")
            project.soundEventAssets.append(newSoundEventAsset)
        }

        public func dismissSoundEventAssetPopover(success: Bool) {
            newSoundEventAssetPopoverIsPresented = false

            // if we got a success, then we don't need to delete the model
            guard !success else {
                return
            }

            guard let editingSoundEventAsset else { return }
            modelContextComponent.modelContext.delete(editingSoundEventAsset)
            _ = modelContextComponent.trySaveModelContext(withMessage: "Something went wrong.")
            self.editingSoundEventAsset = nil
            return
        }

        var technologiesSupported: Bool {
            ARConfiguration.isSupported
        }

    }
}
