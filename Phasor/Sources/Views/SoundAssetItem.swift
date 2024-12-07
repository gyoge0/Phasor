//
//  AudioTrackItemView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/27/24.
//

import AVFoundation
import Foundation
import SwiftData
import SwiftUI

struct SoundAssetItem: View {
    @State var soundAsset: SoundAsset

    @Binding var currentlyPlayingAsset: SoundAsset?
    @Binding var playbackState: PlaybackState
    @Binding var avAudioPlayer: AVAudioPlayer!

    @Environment(\.modelContext) var modelContext: ModelContext

    var renameAction: () -> Void
    var playAsset: (SoundAsset) -> Void

    var body: some View {
        Button {
            if playbackState == .playing && currentlyPlayingAsset == soundAsset {
                avAudioPlayer.pause()
                playbackState = .paused
                return
            }

            if playbackState == .paused && currentlyPlayingAsset == soundAsset {
                avAudioPlayer.play()
                playbackState = .playing
                return
            }

            if playbackState == .playing {
                avAudioPlayer.stop()
            }

            playAsset(soundAsset)

        } label: {
            HStack {
                Text(soundAsset.name)
                Spacer()
                if currentlyPlayingAsset == soundAsset {
                    if playbackState == .playing {
                        Image(systemName: "pause")
                    } else if playbackState == .paused {
                        Image(systemName: "play")
                    }
                }
            }
        }
        .foregroundStyle(.foreground)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(soundAsset)
            } label: {
                Image(systemName: "trash")
            }
            Button(
                action: renameAction,
                label: {
                    Image(systemName: "pencil")
                }
            )
            .tint(.yellow)
        }
    }
}
