//
//  SoundEventAsset.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import MetaCodable
import PHASE
import SwiftData

@Codable
@Inherits(decodable: false, encodable: false)
@Model
public class SoundEventAsset: Identifiable {
    @Attribute(.unique)
    public var id: UUID = UUID()

    public var name: String = "New Sound Event"
    // we allow this to be nil so that when creating we don't pick one by default
    public var soundAsset: SoundAsset! = nil

    public var calibrationLevel: Float = 1.0

    var rawPlaybackMode: Int
    var rawCullOption: Int

    @Relationship(deleteRule: .cascade)
    public var associatedSoundEvents: [SoundEvent] = []

    public init(
        name: String = "New Sound Event",
        soundAsset: SoundAsset! = nil,
        calibrationLevel: Float = 1.0,
        rawPlaybackMode: Int,
        rawCullOption: Int
    ) {
        self.name = name
        self.soundAsset = soundAsset
        self.calibrationLevel = calibrationLevel
        self.rawPlaybackMode = rawPlaybackMode
        self.rawCullOption = rawCullOption
    }
}
