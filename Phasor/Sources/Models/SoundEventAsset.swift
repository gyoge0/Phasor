//
//  SoundEventAsset.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/6/24.
//

import Foundation
import MetaCodable
import PHASE
import SwiftData
import SwiftUI

/// How to play a specific audio track.
@Codable
@Inherits(decodable: false, encodable: false)
@Model
class SoundEventAsset {
    @Attribute(.unique)
    var id: UUID = UUID()

    var name: String = ""

    var rawPlaybackMode: Int! = PHASEPlaybackMode.looping.rawValue

    /** What to do when the audio track ends. */
    @Transient
    var playbackMode: PHASEPlaybackMode {
        get { PHASEPlaybackMode(rawValue: rawPlaybackMode)! }
        set(newValue) { rawPlaybackMode = newValue.rawValue }
    }

    // TODO: document this - is it loudness???
    var calibrationLevel: Double = 1.0

    var rawCullOption: Int! = PHASECullOption.sleepWakeAtRealtimeOffset.rawValue

    /** What to do when the audio source gets out of range. */
    @Transient var cullOption: PHASECullOption {
        get { return PHASECullOption(rawValue: rawCullOption)! }
        set(newValue) { rawCullOption = newValue.rawValue }
    }

    @Relationship(deleteRule: .cascade, inverse: \SoundEvent.eventAsset)
    var associatedSoundEvents: [SoundEvent] = []

    var associatedProjects: [PhasorProject] = []

    var soundAsset: SoundAsset? = nil

    init(name: String = "") {
        self.name = name
    }
}
