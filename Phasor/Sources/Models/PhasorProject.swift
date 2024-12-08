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

    var _rawReverbPreset: Int! = PHASEReverbPreset.mediumHall.rawValue

    @Transient var reverbPreset: PHASEReverbPreset {
        get { return PHASEReverbPreset(rawValue: _rawReverbPreset)! }
        set(newValue) { _rawReverbPreset = newValue.rawValue }
    }

    /** Distance beyond which sound sources stop playing. Must be >= 1. */
    var cullDistance: Double = 1.0

    /**
     Strength of the rolloff effect when moving away from sound sources.
     Values less than one create a quicker roll off and values greater than one create longer roll offs.
     Must be >= 0.
     */
    var rolloffFactor: Double = 1.0

    @Relationship(deleteRule: .cascade, inverse: \PlaybackSource.project)
    var playbackSources: [PlaybackSource] = []
    
    @Relationship(deleteRule: .nullify, inverse: \SoundEventAsset.associatedProjects)
    var soundEventAssets: [SoundEventAsset] = []
    
    @Relationship(deleteRule: .cascade, inverse: \SoundEvent.project)
    var soundEvents: [SoundEvent] = []

    init(name: String = "New Project") {
        self.name = name
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
