//
//  ProjectView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import PHASE
import SwiftData
import SwiftUI

struct ProjectEditorView: View {
    @Binding var project: PhasorProject
    @State var popoverShown: Bool = false
    @Environment(\.modelContext) var modelContext: ModelContext
    // this has to be initialized to something
    // if I do SoundEventAsset! it breaks the binding
    @State var newSoundEventAsset: SoundEventAsset = SoundEventAsset(name: "New Sound Event")

    var body: some View {
        Form {
            Section("Reverb") {
                Picker("Reverb Preset", selection: $project.reverbPreset) {
                    ForEach(PHASEReverbPreset.presets, id: \.self) { preset in
                        Text(preset.getName()).tag(preset)
                    }
                }
            }

            Section("Rolloff") {
                HStack {
                    #if os(macOS)
                        Text("Rolloff Strength:")
                    #else
                        Text("Rolloff Strength")
                    #endif

                    Spacer()
                    Text(project.rolloffFactor.rounded(to: 2).description)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $project.rolloffFactor, in: 0...2, step: 0.01)
            }

            Section("Culling") {
                HStack {
                    #if os(macOS)
                        Text("Cull Distance (m):")
                    #else
                        Text("Cull Distance (m)")
                    #endif

                    Spacer()
                    Text(project.cullDistance.rounded(to: 1).description)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $project.cullDistance, in: 1...10, step: 0.1)
            }

            Section("Events") {
                Button("New Event") {
                    popoverShown = true
                }
                List($project.soundEventAssets, id: \.id) { $item in
                    NavigationLink(
                        item.name,
                        destination: SoundEventAssetEditorView(soundEventAsset: $item)
                    )
                }
            }
        }
        .navigationTitle(project.name)
        .popover(isPresented: $popoverShown) {
            NavigationView {
                SoundEventAssetEditorView(
                    soundEventAsset: $newSoundEventAsset,
                    creatingNewSoundEvent: true
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            popoverShown = false
                            newSoundEventAsset = SoundEventAsset(name: "New Sound Event")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            popoverShown = false
                            newSoundEventAsset.associatedProjects.append(project)
                            modelContext.insert(newSoundEventAsset)
                            newSoundEventAsset = SoundEventAsset(name: "New Sound Event")
                        }
                    }
                }
            }
        }
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

// is this really the best way to do this?
#Preview {
    @Previewable @State
    var assets: [SoundAsset]! = nil
    @Previewable @State
    var eventAssets: [SoundEventAsset]! = nil
    @Previewable @State
    var project = PhasorProject(name: "My Project")
    
    let container = createContainer()

    NavigationStack {
        ProjectEditorView(project: $project)
            .modelContainer(container)
            .onAppear {
                eventAssets = (1...10).map {
                    SoundEventAsset(name: "Sound Event Asset \($0)")
                }

                eventAssets.forEach { container.mainContext.insert($0) }
                container.mainContext.insert(project)

                project.soundEventAssets = eventAssets
            }
    }
}
