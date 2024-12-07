//
//  AudioModelView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/22/24.
//

import AVFoundation
import SwiftData
import SwiftUI

enum PlaybackState {
    case paused
    case playing
    case stopped
}

struct SoundAssetManagerView: View {
    @Query var soundAssets: [SoundAsset]
    @State var filePickerShown: Bool = false
    @Environment(\.modelContext) var modelContext: ModelContext

    @State var selectedAssetForRename: SoundAsset?
    @State var editedAssetName: String = ""
    @State var renameModalShown: Bool = false

    @State var currentlyPlayingAsset: SoundAsset?
    @State var playbackState: PlaybackState = .stopped
    @State var avAudioPlayer: AVAudioPlayer!

    var body: some View {
        NavigationStack {
            List(soundAssets, id: \.id) { soundAsset in
                SoundAssetItem(
                    soundAsset: soundAsset,
                    currentlyPlayingAsset: $currentlyPlayingAsset,
                    playbackState: $playbackState,
                    avAudioPlayer: $avAudioPlayer,
                    renameAction: {
                        selectedAssetForRename = soundAsset
                        editedAssetName = soundAsset.name
                        renameModalShown = true
                    },
                    playAsset: { soundAsset in
                        avAudioPlayer = try! AVAudioPlayer(data: soundAsset.data)
                        guard avAudioPlayer.prepareToPlay() && avAudioPlayer.play() else {
                            #if DEBUG
                                print("couldn't play audio")
                            #endif
                            avAudioPlayer = nil
                            currentlyPlayingAsset = nil
                            playbackState = .stopped
                            return
                        }

                        currentlyPlayingAsset = soundAsset
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
                onCompletion: { result in importAsset(from: result) }
            )
            .overlay {
                if soundAssets.isEmpty {
                    ContentUnavailableView.init(
                        "No Assets",
                        systemImage: "music.note.list",
                        description: Text("Add an asset to get started")
                    )
                }
            }
            .alert(
                "Rename",
                isPresented: $renameModalShown,
                actions: {
                    TextField("Name", text: $editedAssetName)
                    Button("Save") {
                        renameModalShown = false
                        selectedAssetForRename?.name = editedAssetName
                    }.disabled(editedAssetName.isEmpty)
                }
            )
            .navigationTitle("Assets")
            .onDisappear {
                avAudioPlayer.stop()
                playbackState = .stopped
                currentlyPlayingAsset = nil
            }
        }
    }

    private func importAsset(from result: Result<URL, any Error>) {
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

        let audioFormat = try! AVAudioFile(forReading: url).fileFormat

        modelContext.insert(
            SoundAsset(
                name: url.lastPathComponent,
                data: audioData,
                audioFormat: audioFormat
            )
        )
        filePickerShown = false
    }
}

#Preview {
    SoundAssetManagerView()
        .modelContainer(for: [
            SoundAsset.self
        ])
}
