//
//  SoundAsset.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import MetaCodable
import SwiftData

@Codable
@Inherits(decodable: false, encodable: false)
@Model
public class SoundAsset: Identifiable {
    @Attribute(.unique)
    public var id: UUID = UUID()

    public var name: String = "New Sound Asset"
    public var data: Data

    @Relationship(deleteRule: .cascade, inverse: \SoundEventAsset.soundAsset)
    public var associatedSoundEventAssets: [SoundEventAsset] = []

    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}
