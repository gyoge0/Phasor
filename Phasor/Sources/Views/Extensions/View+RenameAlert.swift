//
//  View+RenameAlert.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import SwiftData
import SwiftUI

public struct RenameModal<T: PersistentModel>: ViewModifier {
    @State public var renameModalComponent: RenameModalComponent<T>
    @State private var editingName: String = ""

    public func body(content: Content) -> some View {
        return content.alert(
            "Rename \(renameModalComponent.initialName)",
            isPresented: $renameModalComponent.isPresented,
            actions: {
                TextField("Name", text: $editingName)

                Button("Cancel", role: .cancel) {
                    renameModalComponent.cancelRename()
                    editingName = ""
                }
                Button("Save") {
                    renameModalComponent.confirmRename(newName: editingName)
                    editingName = ""
                }
                .disabled(editingName.isEmpty)
            }
        )
        .onAppear {
            editingName = renameModalComponent.initialName
        }
    }

}

extension View {
    func renameModal<T: PersistentModel>(
        renameModalComponent: RenameModalComponent<T>,
        editingName: String = ""
    ) -> some View {
        self.modifier(RenameModal(renameModalComponent: renameModalComponent))
    }
}
