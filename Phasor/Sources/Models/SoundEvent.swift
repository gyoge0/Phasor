//
//  SoundEvent.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/6/24.
//


import Foundation
import PHASE
import SwiftData
import SwiftUI
import MetaCodable

/// Playback of a SoundEventAsset from a PlaybackSource
@Codable
@Inherits(decodable: false, encodable: false)
@Model
class SoundEvent {


    @Attribute(.unique)
    var id: UUID = UUID()

    var source: PlaybackSource

    var eventAsset: SoundEventAsset
    
    @IgnoreCoding
    var project: PhasorProject? = nil

    init(source: PlaybackSource, eventAsset: SoundEventAsset) {
        self.source = source
        self.eventAsset = eventAsset
    }
}
