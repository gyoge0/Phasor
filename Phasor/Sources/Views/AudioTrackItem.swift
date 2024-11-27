//
//  AudioTrackItemView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/27/24.
//

import Foundation
import SwiftUI
import SwiftData
import AVFoundation

struct AudioTrackItem : View {
    @State var audioTrack: AudioTrackModel
    
    @Binding var currentlyPlayingTrack: AudioTrackModel?
    @Binding var playbackState: PlaybackState
    @Binding var avAudioPlayer: AVAudioPlayer!
    
    @Environment(\.modelContext) var modelContext: ModelContext
    
    var renameAction: () -> Void
    var playTrack: (AudioTrackModel) -> Void
    
    var body: some View {
            Button {
                if playbackState == .playing && currentlyPlayingTrack == audioTrack {
                    avAudioPlayer.pause()
                    playbackState = .paused
                    return
                }

                if playbackState == .paused && currentlyPlayingTrack == audioTrack {
                    avAudioPlayer.play()
                    playbackState = .playing
                    return
                }
                
                if playbackState == .playing {
                    avAudioPlayer.stop()
                }
                
                playTrack(audioTrack)
            
            } label: {
                HStack {
                    Text(audioTrack.name)
                    Spacer()
                    if currentlyPlayingTrack == audioTrack {
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
                    modelContext.delete(audioTrack)
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
