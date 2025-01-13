//
//  View+DeleteAlert.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftData
import SwiftUI

public enum DeleteConfirmationKind {
    case alert
    case confirmationDialog
}

public struct DeleteConfirmation<T: PersistentModel>: ViewModifier {
    @State public var deleteConfirmationComponent: DeleteConfirmationComponent<T>
    public var kind: DeleteConfirmationKind

    @Environment(\.dismiss) private var dismissAction

    /*
     Some notes on why we only confirm delete after the view disappears
     for a confirmationDialog

     Background:
     Whenever confirmationDialog is used, we are deleting from a view for
     the current item. Previously, a less specific closure "onConfirm" was
     taken instead that would be called after confirming the delete. In
     the caller, this always just dismissed from the current navigation
     stack item. Technically, this modifier didn't need to know that so
     I went the route with the clore.

     The problem:
     Whenever the ProjectEditor deleted the current project, it would just
     crash. I traced this to the list of sound event asset links in the
     project editor, since that view would update and try to retrieve the
     properties of non existent sound event assets. I tried to play around
     with how I would delete the models, but no matter what I just kept
     getting the same error since the view would still be updating.

     The solution:
     Instead of deleting immediately, if we are in a confirmationDialog
     then we wait until the main view disappears to finish the delete.
     This way, that list view has no chance to update. This does make the
     code worse (which is why I'm writing this essay), since now this
     modifier knows about the whole navigation stack and dismiss thing
     (since it is calling dismiss). However, this seems to fix the
     problem.

     What is NOT a solution:
     Dealing with only temporary models. This problem only applies when
     deleting saved models, and it's not why I went to inserting before
     save for the models.

     Other possible solutions:
     Use GRDB.swift
     Write from scratch
        This problem isn't in the old app or my demo app. I don't know
        what those are doing differently to cause this to just die.
     */

    public func body(content: Content) -> some View {
        let name = deleteConfirmationComponent.getModelName()

        let title = "Delete \(name)"
        let isPresented = $deleteConfirmationComponent.isPresented

        // without all this view builder stuff theres errors
        @ViewBuilder var body: some View {
            Button(
                "Cancel",
                role: .cancel,
                action: {
                    deleteConfirmationComponent.cancelDelete()
                }
            )
            Button(
                "Delete",
                role: .destructive,
                action: {
                    switch kind {
                    case .alert:
                        deleteConfirmationComponent.confirmDelete()
                    case .confirmationDialog:
                        dismissAction.callAsFunction()
                    }
                }
            )
        }

        @ViewBuilder var message: some View {
            Text(deleteConfirmationComponent.getMessage())
        }

        @ViewBuilder var returnValue: some View {
            switch kind {
            case .alert:
                content.alert(
                    title,
                    isPresented: isPresented,
                    actions: { return body },
                    message: { return message }
                )
            case .confirmationDialog:
                content.confirmationDialog(
                    title,
                    isPresented: isPresented,
                    actions: { return body },
                    message: { return message }
                )
                .onDisappear {
                    deleteConfirmationComponent.confirmDelete()
                }
            }
        }

        return returnValue
    }
}

extension View {
    func deleteConfirmation<T>(
        deleteConfirmationComponent: DeleteConfirmationComponent<T>,
        kind: DeleteConfirmationKind
    ) -> some View {
        return self.modifier(
            DeleteConfirmation(
                deleteConfirmationComponent: deleteConfirmationComponent,
                kind: kind
            )
        )
    }
}
