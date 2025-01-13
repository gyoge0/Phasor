//
//  AudioPlayer.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import AVFoundation
import Foundation

class AudioPlayer {
    public var currentlyPlayingAsset: SoundAsset? = nil
    public var playbackState: PlaybackState = PlaybackState.stopped

    private var avAudioPlayer: AVAudioPlayer? = nil

    public func handleAsset(asset: SoundAsset) throws {
        // a bit scary
        switch playbackState {
        case .playing:
            if currentlyPlayingAsset == asset {
                doWithPlayer { $0.pause() }
                playbackState = .paused
            } else {
                try playNewAsset(asset: asset)
                playbackState = .playing
            }
        case .paused:
            if currentlyPlayingAsset == asset {
                doWithPlayer { $0.play() }
                playbackState = .playing
            } else {
                try playNewAsset(asset: asset)
                playbackState = .playing
            }
        case .stopped:
            try playNewAsset(asset: asset)
            playbackState = .playing
        }

    }

    public func playNewAsset(asset: SoundAsset) throws {
        doWithPlayer { $0.stop() }

        let newPlayer = try AVAudioPlayer(data: asset.data)
        newPlayer.play()
        avAudioPlayer = newPlayer
        currentlyPlayingAsset = asset
        playbackState = .playing
    }

    private func doWithPlayer(_ body: (AVAudioPlayer) -> Void) {
        if let avAudioPlayer {
            body(avAudioPlayer)
        }
    }

    public func stop() {
        playbackState = .stopped
        doWithPlayer { $0.stop() }
        avAudioPlayer = nil
    }
}

enum PlaybackState {
    case playing
    case paused
    case stopped
}
