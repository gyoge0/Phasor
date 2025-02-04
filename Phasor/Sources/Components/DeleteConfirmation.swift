//
//  DeleteComponent.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import Foundation
import SwiftData

@Observable
public class DeleteConfirmationComponent<T: PersistentModel> {
    public var isPresented: Bool = false

    public var confirmationText: (T) -> String
    public var namePath: KeyPath<T, String>
    public var retrieveDependencies: (T) -> [[any PersistentModel]] = { _ in [[]] }
    public var modelContextComponent: ModelContextComponent

    private var deletingModel: T? = nil

    init(
        confirmationText: ((T) -> String)? = nil,
        namePath: KeyPath<T, String>,
        modelContextComponent: ModelContextComponent
    ) {
        self.namePath = namePath
        self.modelContextComponent = modelContextComponent

        if let confirmationText {
            self.confirmationText = confirmationText
        } else {
            self.confirmationText = { model in
                let name = model[keyPath: namePath]
                return "Are you sure you want to delete \(name)?"
            }
        }
    }

    public func startDeleteAsset(model: T) {
        self.deletingModel = model
        self.isPresented = true
    }

    public func cancelDelete() {
        self.isPresented = false
        self.deletingModel = nil
    }

    public func confirmDelete() {
        self.isPresented = false

        guard let deletingModel else { return }
        let name = getModelName()
        self.deletingModel = nil

        _ = modelContextComponent.delete(deletingModel).map {
            modelContextComponent.trySaveModelContext(
                withMessage: "Couldn't save \(name)"
            )
        }
    }

    public func getModelName() -> String {
        guard let deletingModel else { return "" }
        return deletingModel[keyPath: namePath]
    }

    public func getMessage() -> String {
        guard let deletingModel else { return "" }
        return self.confirmationText(deletingModel)
    }
}
