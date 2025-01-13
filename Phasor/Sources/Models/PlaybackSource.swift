//
//  PlaybackSource.swift
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
public class PlaybackSource: Identifiable {
    @Attribute(.unique)
    public var id: UUID = UUID()

    var rawTransform: [Float] = []

    init(rawTransform: [Float]) {
        self.rawTransform = rawTransform
    }
}
