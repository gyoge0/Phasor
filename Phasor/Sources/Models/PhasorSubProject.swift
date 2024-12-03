//
//  PhasorProject.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/28/24.
//

import Foundation
import SwiftData
import PHASE
import SwiftUI

@Model
class PhasorSubProject {
    @Attribute(.unique)
    var id = UUID()
    
    var name: String
    
    var _rawReverbPreset: Int! = nil
    
    @Transient
    var reverbPreset: PHASEReverbPreset {
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

/**
 A point in space from which audio can be played.
 */
@Model
class PlaybackSource {
    @Attribute(.unique)
    var id = UUID()
    
    var rawTransform: [Float]! = nil
    
    @Transient
    var transform: simd_float4x4 {
        get {
            // swift-format-ignore
            return simd_float4x4(
                rawTransform[0],  rawTransform[1],  rawTransform[2],  rawTransform[3],
                rawTransform[4],  rawTransform[5],  rawTransform[6],  rawTransform[7],
                rawTransform[8],  rawTransform[9],  rawTransform[10], rawTransform[11],
                rawTransform[12], rawTransform[13], rawTransform[14], rawTransform[15]
            )
        }
        set(newValue) {
            // swift-format-ignore
            rawTransform = [
                newValue.columns.0.x, newValue.columns.1.x, newValue.columns.2.x, newValue.columns.3.x,
                newValue.columns.0.y, newValue.columns.1.y, newValue.columns.2.y, newValue.columns.3.y,
                newValue.columns.0.z, newValue.columns.1.z, newValue.columns.2.z, newValue.columns.3.z,
                newValue.columns.0.w, newValue.columns.1.w, newValue.columns.2.w, newValue.columns.3.w
            ]
        }
    }
    
    init(transform: simd_float4x4) {
        self.transform = transform
    }
}

/**
 Audio track data.
 */
@Model
class SoundAsset {
    @Attribute(.unique)
    var id = UUID()
    
    var name: String
    
    var data: Data
    
    private var rawAudioFormat: Data? = nil
    
    @Transient
    var audioFormat: AVAudioFormat? {
        get {
            guard let rawAudioFormat else {
                return nil
            }
            guard let unArchived = try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: AVAudioFormat.self,
                from: rawAudioFormat
            ) else {
                return nil
            }
            
            return unArchived
        }
        set(newValue) {
            guard let newValue = newValue else {
                return
            }
            
            let newData = try? NSKeyedArchiver
                .archivedData(withRootObject: newValue, requiringSecureCoding: false)
            
            if newData != nil {
                rawAudioFormat = newData
            }
        }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \SoundEventAsset.soundAsset)
    var associatedSoundEventAssets: [SoundEventAsset]
    
    init(
        name: String = "New Asset",
        data: Data,
        audioFormat: AVAudioFormat,
        associatedSoundEventAssets: [SoundEventAsset] = []
    ) {
        self.name = name
        self.data = data
        self.associatedSoundEventAssets = associatedSoundEventAssets
        
        self.audioFormat = audioFormat
    }
}

/**
 How to play a specific audio track.
 */
@Model
class SoundEventAsset {
    @Attribute(.unique)
    var id = UUID()
    
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
    @Transient
    var cullOption: PHASECullOption {
        get { return PHASECullOption(rawValue: rawCullOption)!}
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

/**
 Playback of a SoundEventAsset from a PlaybackSource
 */
@Model
class SoundEvent {
    @Attribute(.unique)
    var id = UUID()
    
    var source: PlaybackSource
    
    var eventAsset: SoundEventAsset
    
    init(source: PlaybackSource, eventAsset: SoundEventAsset) {
        self.source = source
        self.eventAsset = eventAsset
    }
}
