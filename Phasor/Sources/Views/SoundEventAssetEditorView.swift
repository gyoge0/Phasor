//
//  SoundEventAssetEditorView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/8/24.
//

import SwiftUI
import SwiftData
import PHASE
import AVFoundation

struct SoundEventAssetEditorView: View {
    @Binding var soundEventAsset: SoundEventAsset
    @Query var soundAssets: [SoundAsset]
    @State var playbackState: PlaybackState = .stopped
    @State var avAudioPlayer: AVAudioPlayer!
    @State var renameModalShown: Bool = false
    @State var editedEventAssetName: String = ""
    @Environment(\.modelContext) var modelContext: ModelContext
    @Environment(\.dismiss) var dismiss: DismissAction
    @State var currentlyPlayingAsset: SoundAsset?
    @State var creatingNewSoundEvent: Bool = false
    
    var unusedSoundAssets: [SoundAsset] {
        get {
            soundAssets.filter { !soundEventAsset.soundAssets.contains($0)}
        }
    }
    
    var body: some View {
        Form {
            Section("Playback Settings") {
                Toggle(isOn: Binding(
                    get: { soundEventAsset.playbackMode == .looping},
                    set: { soundEventAsset.playbackMode = $0 ? .looping : .oneShot}
                )) {
                    Text("Loop Audio")
                }
                
                Picker("Culling Mode", selection: $soundEventAsset.cullOption) {
                    ForEach(PHASECullOption.options, id: \.self) { cullOption in
                        Text(cullOption.getName()).tag(cullOption)
                    }
                }
                
                HStack {
                    #if os(macOS)
                        Text("Calibration Level:")
                    #else
                        Text("Calibration Level")
                    #endif

                    Spacer()
                    Text( soundEventAsset.calibrationLevel .rounded(to: 2).description )
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $soundEventAsset.calibrationLevel,
                    in: 0...2,
                    step: 0.01
                )
            }
            
            Section("Audio") {
                Menu {
                    ForEach(unusedSoundAssets , id: \.id) { soundAsset in
                        Button(soundAsset.name) {
                            soundEventAsset.soundAssets.append(soundAsset)
                        }
                    }
                } label : {
                    // TODO: the menu is centered on the hstack
                    HStack {
                        Text("Add Asset")
                        Spacer()
                    }
                }
                .disabled(unusedSoundAssets.isEmpty)
                
                List(soundEventAsset.soundAssets, id: \.id) { soundAsset in
                    SoundAssetItem(
                        soundAsset: soundAsset,
                        currentlyPlayingAsset: $currentlyPlayingAsset,
                        playbackState: $playbackState,
                        avAudioPlayer: $avAudioPlayer,
                        renameAction: nil,
                        deleteAction: {
                            if currentlyPlayingAsset == soundAsset {
                                currentlyPlayingAsset = nil
                                playbackState = .stopped
                                avAudioPlayer.stop()
                            }
                            soundEventAsset.soundAssets.removeAll { $0 == soundAsset}
                            soundAsset.associatedSoundEventAssets.removeAll { $0 == soundEventAsset }
                        },
                        playAsset: { _ in
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
            }
            
            Button {
                renameModalShown = true
                editedEventAssetName = soundEventAsset.name
            } label: {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(soundEventAsset.name).foregroundStyle(.selection)
                }
            }.foregroundStyle(.foreground)
            
            if !creatingNewSoundEvent {
                Button(role: .destructive) {
                    modelContext.delete(soundEventAsset)
                    dismiss.callAsFunction()
                } label: {
                    Text("Delete \(soundEventAsset.name)")
                }
            }
        }
        .navigationTitle(soundEventAsset.name)
        .navigationBarTitleDisplayMode(creatingNewSoundEvent ? .inline : .large)
        .onDisappear {
            if let avAudioPlayer {
                avAudioPlayer.stop()
            }
            playbackState = .stopped
        }
        .alert(
            "Rename",
            isPresented: $renameModalShown,
            actions: {
                TextField("Name", text: $editedEventAssetName)
                Button("Cancel") {
                    renameModalShown = false
                }
                Button("Save") {
                    renameModalShown = false
                    soundEventAsset.name = editedEventAssetName
                }.disabled(editedEventAssetName.isEmpty)
            }
        )
    }
}


// todo: find a better way to mock for previews
@MainActor
private func createContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: PhasorProject.self,
        PlaybackSource.self,
        SoundAsset.self,
        SoundEvent.self,
        SoundEventAsset.self,
        configurations: config
    )

    return container
}


#Preview {
    @Previewable @State
    var soundEventAsset = SoundEventAsset(
        name: "My Sound Event"
    )
    
    let container = createContainer()
    
    NavigationStack {
        SoundEventAssetEditorView(soundEventAsset: $soundEventAsset)
            .modelContainer(container)
            .onAppear {
                container.mainContext.insert(soundEventAsset)
            }
    }
}
