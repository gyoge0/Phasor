//
//  DocumentHomeView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/22/25.
//

import SwiftUI
import SwiftData

struct DocumentHomeView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var projects: [PhasorProject]
    
    var body: some View {
        TabView {
            Tab("Project", systemImage: "folder") {
                if let project = projects.first {
                    ProjectEditorView(project: project)
                } else {
                    Text("Something went wrong")
                }
            }
            Tab("Library", systemImage: "waveform") {
                SoundAssetLibraryView()
            }
        }
    }
}

#Preview {
    DocumentHomeView()
}
