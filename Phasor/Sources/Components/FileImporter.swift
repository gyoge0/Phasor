//
//  FileImporter.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 2/14/25.
//

import Foundation
import SwiftData

@Observable
public class FileImporterComponent {
    public var modelContextComponent: ModelContextComponent
    public var errorMessageComponent: ErrorMessageComponent

    public init(
        modelContextComponent: ModelContextComponent,
        errorMessageComponent: ErrorMessageComponent
    ) {
        self.modelContextComponent = modelContextComponent
        self.errorMessageComponent = errorMessageComponent
    }

    public func importFile(url: URL, name: String?) -> SoundAsset? {
        // this can fail if we try to open something in the bundle (for onboarding)
        // doesn't matter if this fails on real files since it gets caught on the next guard
        _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }

        guard let data = try? Data(contentsOf: url) else {
            errorMessageComponent.message = "Something went wrong reading the file."
            errorMessageComponent.isPresented = true
            return nil
        }

        let soundAsset = SoundAsset(name: name ?? url.lastPathComponent, data: data)

        return soundAsset
    }

}
