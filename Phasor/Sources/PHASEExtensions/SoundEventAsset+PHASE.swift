//
//  SoundEventAsset+PHASE.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import PHASE

extension SoundEventAsset {
    public var playbackMode: PHASEPlaybackMode {
        get { PHASEPlaybackMode(rawValue: rawPlaybackMode)! }
        set(newValue) { rawPlaybackMode = newValue.rawValue }
    }

    public var cullOption: PHASECullOption {
        get { PHASECullOption(rawValue: rawCullOption)! }
        set(newValue) { rawCullOption = newValue.rawValue }
    }

    public convenience init(
        name: String = "New Sound Event",
        soundAsset: SoundAsset! = nil,
        calibrationLevel: Float = 1.0,
        playbackMode: PHASEPlaybackMode = .looping,
        cullOption: PHASECullOption = .sleepWakeAtRealtimeOffset
    ) {
        self.init(
            name: name,
            soundAsset: soundAsset,
            calibrationLevel: calibrationLevel,
            rawPlaybackMode: playbackMode.rawValue,
            rawCullOption: cullOption.rawValue
        )
    }
}
