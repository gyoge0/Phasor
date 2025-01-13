//
//  ProjectLibraryView+ViewModel.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import AVFoundation
import Foundation
import SwiftData
import SwiftUI

extension ProjectLibraryView {
    @Observable
    class ViewModel {
        // it is up to our view to pass this back to us
        var modelContext: ModelContext! = nil {
            didSet {
                modelContextComponent.modelContext = modelContext
            }
        }

        public var newProjectPopoverIsPresented: Bool = false
        public var editingProject: PhasorProject? = nil

        public var errorMessageComponent: ErrorMessageComponent
        public var modelContextComponent: ModelContextComponent
        public var deleteConfirmationComponent: DeleteConfirmationComponent<PhasorProject>
        public var renameModalComponent: RenameModalComponent<PhasorProject>

        init() {
            // construct dependency graph
            let errorMessageComponent = ErrorMessageComponent()
            let modelContextComponent = ModelContextComponent(
                errorMessageComponent: errorMessageComponent
            )
            let deleteConfirmationComponent = DeleteConfirmationComponent<PhasorProject>(
                namePath: \PhasorProject.name,
                modelContextComponent: modelContextComponent
            )
            let renameModalComponent = RenameModalComponent(
                namePath: \PhasorProject.name,
                modelContextComponent: modelContextComponent
            )

            // assign all at once
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
            self.deleteConfirmationComponent = deleteConfirmationComponent
            self.renameModalComponent = renameModalComponent
        }

        public func newItem() {
            let newProject = PhasorProject()
            editingProject = newProject
            // show the popup before inserting model
            // otherwise you can see the ui change for a split second
            // TODO: can still see the project pop up for a split second
            newProjectPopoverIsPresented = true

            // we will insert now, and delete if cancelled
            modelContextComponent.modelContext.insert(newProject)
        }

        public func dismissProjectPopover(success: Bool) {
            newProjectPopoverIsPresented = false

            // if we got a success, then we don't need to delete the model
            guard !success else { return }

            guard let editingProject else { return }
            modelContextComponent.modelContext.delete(editingProject)
            _ = modelContextComponent.trySaveModelContext(withMessage: "Something went wrong.")
            self.editingProject = nil
            return
        }
    }
}
