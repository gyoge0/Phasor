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
    
    var trackUrl: URL?
    
    @Relationship(deleteRule: .nullify, inverse: \AudioSourceModel.audioTrack)
    var audioSources: [AudioSourceModel]
    
    init(
        name: String,
        trackData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.audioSources = []
        
        if let data = trackData {
            setTrackData(data)
        } else {
            trackUrl = nil
        }
    }
    
    func setTrackData(_ data: Data) {
        do {
            if FileManager.default.fileExists(atPath: "trackData/\(id)") {
                try FileManager.default.removeItem(atPath: "trackData/\(id)")
            }
            FileManager.default.createFile(atPath: "trackData/\(id)", contents: data)
        } catch {
            trackUrl = nil
        }
    }
    
}
