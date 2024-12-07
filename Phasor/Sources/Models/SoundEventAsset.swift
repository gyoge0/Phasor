//
//  SoundEventAsset.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/6/24.
//


import Foundation
import PHASE
import SwiftData
import SwiftUI
import MetaCodable

/// How to play a specific audio track.
@Codable
@Inherits(decodable: false, encodable: false)
@Model
class SoundEventAsset {
    @Attribute(.unique)
    var id: UUID = UUID()

    /** The audio track to play back. */
    var soundAsset: SoundAsset

    var rawPlaybackMode: Int! = nil

    /** What to do when the audio track ends. */
    @Transient
    var playbackMode: PHASEPlaybackMode {
        get { PHASEPlaybackMode(rawValue: rawPlaybackMode)! }
        set(newValue) { rawPlaybackMode = newValue.rawValue }
    }

    // TODO: document this - is it loudness???
    var calibrationLevel: Double

    var rawCullOption: Int! = nil

    /** What to do when the audio source gets out of range. */
    @Transient var cullOption: PHASECullOption {
        get { return PHASECullOption(rawValue: rawCullOption)! }
        set(newValue) { rawCullOption = newValue.rawValue }
    }

    @Relationship(deleteRule: .cascade, inverse: \SoundEvent.eventAsset)
    var associatedSoundEvents: [SoundEvent]

    init(
        soundAsset: SoundAsset,
        playbackMode: PHASEPlaybackMode,
        calibrationLevel: Double = 1.0,
        cullOption: PHASECullOption = .sleepWakeAtRealtimeOffset,
        associatedSoundEvents: [SoundEvent] = []
    ) {
        self.soundAsset = soundAsset
        self.calibrationLevel = calibrationLevel
        self.associatedSoundEvents = associatedSoundEvents

        self.playbackMode = playbackMode
        self.cullOption = cullOption
    }
}
