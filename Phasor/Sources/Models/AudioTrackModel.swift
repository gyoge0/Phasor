//
//  AudioTrackModel.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/22/24.
//

import Foundation
import SwiftData


@Model
class AudioTrackModel {
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    
    @Attribute(.externalStorage)
    var trackData: Data
    
    @Relationship(deleteRule: .nullify, inverse: \AudioSourceModel.audioTrack)
    var audioSources: [AudioSourceModel]
    
    init(
        name: String,
        trackData: Data
    ) {
        self.id = UUID()
        self.audioSources = []
        
        self.name = name
        self.trackData = trackData
    }
    
}
