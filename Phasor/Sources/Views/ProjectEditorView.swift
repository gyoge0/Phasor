//
//  ProjectView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import SwiftData
import SwiftUI
import PHASE

struct ProjectEditorView: View {
    @Binding var project: PhasorProject
    @State var popoverShown: Bool = false

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
                Button("Add Event") {
                    popoverShown = true
                }
                
                List(project.soundEventAssets, id: \.id) { item in
                    NavigationLink(SoundEventAssetEditor(item)) {
                        Text(item.name)
                    }
                }
            }
        }
        .navigationTitle(project.name)
        .popover(isPresented: $popoverShown) {
//            SoundEventAssetEditor()
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
    
    let project = PhasorProject(name: "My Project")
    container.mainContext.insert(project)
    
    return container
}

#Preview {
    @Previewable @State
    var project = PhasorProject()
    
    NavigationStack {
        ProjectEditorView(project: $project)
            .modelContainer(createContainer())
    }
}
