//
//  AudioSourceModel.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/22/24.
//

import Foundation
import SwiftData


@Model
class AudioSourceModel {
    @Attribute(.unique)
    var id: UUID
    
    var audioTrack: AudioTrackModel?
    
    init(id: UUID, audioTrack: AudioTrackModel) {
        self.id = id
        self.audioTrack = audioTrack
    }
}
