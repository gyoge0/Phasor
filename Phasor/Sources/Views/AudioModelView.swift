//
//  AudioModelView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/22/24.
//

import SwiftUI
import SwiftData
import AVFoundation

enum PlaybackState {
    case paused
    case playing
    case stopped
}

struct AudioModelView: View {
    @Query var audioTracks: [AudioTrackModel]
    @State var filePickerShown: Bool = false
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @State var selectedTrackForRename: AudioTrackModel?
    @State var editedTrackName: String = ""
    @State var renameModalShown: Bool = false
    
    @State var currentlyPlayingTrack: AudioTrackModel?
    @State var playbackState: PlaybackState = .stopped
    @State var avAudioPlayer: AVAudioPlayer!
    
    var body: some View {
        NavigationStack {
            List(audioTracks, id: \.id) { audioTrack in
                AudioTrackItem(
                    audioTrack: audioTrack,
                    currentlyPlayingTrack: $currentlyPlayingTrack,
                    playbackState: $playbackState,
                    avAudioPlayer: $avAudioPlayer,
                    renameAction: {
                        selectedTrackForRename = audioTrack
                        editedTrackName = audioTrack.name
                        renameModalShown = true
                    },
                    playTrack: { audioTrack in
                        avAudioPlayer = try! AVAudioPlayer( data: audioTrack.trackData )
                        guard avAudioPlayer.prepareToPlay() && avAudioPlayer.play() else {
#if DEBUG
                            print("couldn't play audio")
#endif
                            avAudioPlayer = nil
                            currentlyPlayingTrack = nil
                            playbackState = .stopped
                            return
                        }

                        currentlyPlayingTrack = audioTrack
                        playbackState = .playing
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { filePickerShown = true }) {
                        Image(systemName: "waveform.path.badge.plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $filePickerShown,
                allowedContentTypes: [.audio],
                onCompletion: { result in importTrack(from: result) }
            )
            .overlay {
                if audioTracks.isEmpty {
                    ContentUnavailableView.init("No tracks", systemImage: "tray", description: Text("Add a track to get started"))
                }
            }
            .alert("Rename", isPresented: $renameModalShown, actions: {
                TextField("Name", text: $editedTrackName)
                Button("Save") {
                    renameModalShown = false
                    selectedTrackForRename?.name = editedTrackName
                }.disabled(editedTrackName.isEmpty)
            })
            .navigationTitle("Tracks")
        }
    }
    
    
    private func importTrack(from result: Result<URL, any Error>) {
        guard case .success(let url) = result else {
#if DEBUG
            print("file picker failure")
#endif
            return
        }
        
        guard url.startAccessingSecurityScopedResource() else {
#if DEBUG
            print("accessing security scoped resources failure")
#endif
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let audioData = try? Data(contentsOf: url) else {
#if DEBUG
            print("couldn't load url into data")
#endif
            return
        }

        modelContext.insert(AudioTrackModel(
            name: url.lastPathComponent,
            trackData: audioData
        ))
        filePickerShown = false
    }
}



#Preview {
    AudioModelView()
        .modelContainer(for: [
            AudioTrackModel.self
        ])
}
