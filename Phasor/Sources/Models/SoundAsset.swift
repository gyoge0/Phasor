//
//  SoundAsset.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/6/24.
//

import Foundation
import MetaCodable
import PHASE
import SwiftData
import SwiftUI

/// Audio track data.
@Codable
@Inherits(decodable: false, encodable: false)
@Model
class SoundAsset {
    @Attribute(.unique)
    var id: UUID = UUID()

    var name: String

    var data: Data

    var associatedSoundEventAssets: [SoundEventAsset] = []

    init(
        name: String = "New Asset",
        data: Data
    ) {
        self.name = name
        self.data = data
    }
}
