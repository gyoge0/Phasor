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

    private var rawAudioFormat: Data? = nil

    @Transient var audioFormat: AVAudioFormat? {
        get {
            guard let rawAudioFormat else {
                return nil
            }
            guard
                let unArchived = try? NSKeyedUnarchiver.unarchivedObject(
                    ofClass: AVAudioFormat.self,
                    from: rawAudioFormat
                )
            else {
                return nil
            }

            return unArchived
        }
        set(newValue) {
            guard let newValue = newValue else {
                return
            }

            let newData =
                try? NSKeyedArchiver
                .archivedData(withRootObject: newValue, requiringSecureCoding: false)

            if newData != nil {
                rawAudioFormat = newData
            }
        }
    }

    var associatedSoundEventAssets: [SoundEventAsset] = []

    init(
        name: String = "New Asset",
        data: Data,
        audioFormat: AVAudioFormat
    ) {
        self.name = name
        self.data = data
        self.associatedSoundEventAssets = associatedSoundEventAssets
    }
}
