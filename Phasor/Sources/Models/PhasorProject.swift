//
//  PhasorSubProject.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/6/24.
//


import Foundation
import PHASE
import SwiftData
import SwiftUI
import MetaCodable

@Codable
@Inherits(decodable: false, encodable: false)
@Model
class PhasorProject {
    @Attribute(.unique)
    var id: UUID = UUID()

    var name: String

    var _rawReverbPreset: Int! = nil

    @Transient var reverbPreset: PHASEReverbPreset {
        get { return PHASEReverbPreset(rawValue: _rawReverbPreset)! }
        set(newValue) { _rawReverbPreset = newValue.rawValue }
    }

    /** Distance beyond which sound sources stop playing. Must be >= 1. */
    var cullDistance: Double

    /**
     Strength of the rolloff effect when moving away from sound sources.
     Values less than one create a quicker roll off and values greater than one create longer roll offs.
     Must be >= 1.
     */
    var rolloffFactor: Double

    var playbackSources: [PlaybackSource]

    var soundAssets: [SoundAsset]

    var soundEventAssets: [SoundEventAsset]

    var soundEvents: [SoundEvent]

    init(
        name: String = "New Project",
        reverbPreset: PHASEReverbPreset = .mediumRoom,
        cullDistance: Double = 1.0,
        rolloffFactor: Double = 1.0,
        playbackSources: [PlaybackSource] = [],
        soundAssets: [SoundAsset] = [],
        soundEventAssets: [SoundEventAsset] = [],
        soundEvents: [SoundEvent] = []
    ) {
        self.name = name
        self.cullDistance = cullDistance
        self.rolloffFactor = rolloffFactor
        self.playbackSources = playbackSources
        self.soundAssets = soundAssets
        self.soundEventAssets = soundEventAssets
        self.soundEvents = soundEvents

        self.reverbPreset = reverbPreset
    }
    
}

extension PhasorProject : Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .phasorProject)
    }
}

extension UTType {
    static var phasorProject = UTType(
        exportedAs: "com.gyoge.phasor.phasorproject",
        conformingTo: .package
    )
}
