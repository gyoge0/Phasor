//
//  SoundAssetItemView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import SwiftUI

struct SoundAssetItemView: View {
    var soundAsset: SoundAsset
    var playbackState: PlaybackState

    var onTap: (SoundAsset) -> Void = { _ in }
    var onRename: (SoundAsset) -> Void = { _ in }
    var onDelete: (SoundAsset) -> Void = { _ in }

    var body: some View {
        HStack {
            Text(soundAsset.name)
            Spacer()
            if playbackState != .stopped {
                Image(systemName: playbackState == .playing ? "pause" : "play")
            }
        }
        .onTapGesture { onTap(soundAsset) }
        .trashSwipe { onDelete(soundAsset) }
        .renameSwipe { onRename(soundAsset) }
    }
}

#Preview {
    @Previewable
    @State
    var playbackState: PlaybackState = PlaybackState.stopped

    VStack {
        List {
            SoundAssetItemView(
                soundAsset: SoundAsset(
                    name: "My Sound Asset",
                    data: .init()
                ),
                playbackState: playbackState
            )
            Picker(selection: $playbackState, label: Text("Playback State")) {
                Text("Stopped").tag(PlaybackState.stopped)
                Text("Paused").tag(PlaybackState.paused)
                Text("Playing").tag(PlaybackState.playing)
            }
        }
    }
}
