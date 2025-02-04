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
    
    public func delete(soundEvent: SoundEvent) {
        modelContext.delete(soundEvent)
    }
    
    public func delete(soundEventAsset: SoundEventAsset) {
        soundEventAsset.associatedSoundEvents.forEach { delete(soundEvent: $0) }
        modelContext.delete(soundEventAsset)
    }
    
    public func delete(soundAsset: SoundAsset) {
        soundAsset.associatedSoundEventAssets
            .forEach { delete(soundEventAsset: $0) }
        modelContext.delete(soundAsset)
    }
    
    public func delete(project: PhasorProject) {
        project.soundEvents.forEach { delete(soundEvent: $0) }
        project.soundEventAssets.forEach { delete(soundEventAsset: $0) }
        modelContext.delete(project)
    }
    
    public enum DeleteError: Error {
        case unknownModel
    }
    public func delete(_ model: any PersistentModel) -> Result<(), DeleteError> {
        switch model {
        case let project as PhasorProject:
            delete(project: project)
        case let soundAsset as SoundAsset:
            delete(soundAsset: soundAsset)
        case let soundEventAsset as SoundEventAsset:
            delete(soundEventAsset: soundEventAsset)
        case let soundEvent as SoundEvent:
            delete(soundEvent: soundEvent)
        default:
            return Result.failure(DeleteError.unknownModel)
        }
        return Result.success(())
    }
    
}
