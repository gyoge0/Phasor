//
//  PhasorProject.swift
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
public class PhasorProject: Identifiable {
    @Attribute(.unique)
    public var id: UUID = UUID()

    public var name: String = "New Project"
    public var cullDistance: Double = 1.0
    public var rolloffFactor: Double = 1.0

    var rawReverbPreset: Int = PHASEReverbPreset.mediumHall.rawValue

    @Relationship(deleteRule: .cascade)
    public var soundEventAssets: [SoundEventAsset] = []

    @Relationship(deleteRule: .cascade)
    public var soundEvents: [SoundEvent] = []

    init(
        name: String = "New Project",
        cullDistance: Double = 1.0,
        rolloffFactor: Double = 1.0,
        rawReverbPreset: Int = PHASEReverbPreset.mediumHall.rawValue
    ) {
        self.name = name
        self.cullDistance = cullDistance
        self.rolloffFactor = rolloffFactor
        self.rawReverbPreset = rawReverbPreset
    }
}
