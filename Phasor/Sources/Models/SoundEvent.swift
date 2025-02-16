//
//  SoundEvent.swift
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
public class SoundEvent: Identifiable {
    @Attribute(.unique)
    public var id: UUID = UUID()

    public var soundEventAsset: SoundEventAsset
    public var playbackSource: PlaybackSource

    public init(
        soundEventAsset: SoundEventAsset,
        playbackSource: PlaybackSource
    ) {
        self.soundEventAsset = soundEventAsset
        self.playbackSource = playbackSource
    }
}
