//
//  ModelContext.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import Foundation
import SwiftData

@Observable
public class ModelContextComponent {
    public var modelContext: ModelContext!
    public var errorMessageComponent: ErrorMessageComponent

    public init(
        modelContext: ModelContext! = nil,
        errorMessageComponent: ErrorMessageComponent
    ) {
        self.modelContext = modelContext
        self.errorMessageComponent = errorMessageComponent
    }

    public func trySaveModelContext(withMessage message: String) -> Bool {
        do {
            try modelContext.save()
            return true
        } catch {
            errorMessageComponent.message = message
            errorMessageComponent.isPresented = true
            return false
        }
    }
}
