//
//  RenameModal.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import Foundation
import SwiftData

@Observable
public class RenameModalComponent<T: PersistentModel> {
    public var isPresented: Bool = false
    public var initialName: String = ""

    public var namePath: WritableKeyPath<T, String>
    public var modelContextComponent: ModelContextComponent

    private var renamingModel: T? = nil

    public var modelName: String {
        get {
            guard let renamingModel else { return "" }
            return renamingModel[keyPath: namePath]
        }
        set {
            guard var renamingModel else { return }
            renamingModel[keyPath: namePath] = newValue
        }
    }

    init(
        namePath: WritableKeyPath<T, String>,
        modelContextComponent: ModelContextComponent
    ) {
        self.namePath = namePath
        self.modelContextComponent = modelContextComponent
    }

    public func startRenameAsset(model: T) {
        self.renamingModel = model
        self.initialName = modelName

        self.isPresented = true
    }

    public func cancelRename() {
        self.isPresented = false
        self.initialName = ""

        self.modelName = initialName
        self.renamingModel = nil
    }

    public func confirmRename(newName: String) {
        self.isPresented = false
        self.initialName = ""

        guard renamingModel != nil else { return }
        modelName = newName
        self.renamingModel = nil

        _ = modelContextComponent.trySaveModelContext(withMessage: "Couldn't save \(newName)")
    }
}
