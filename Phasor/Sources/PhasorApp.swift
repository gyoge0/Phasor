//
//  PhasorApp.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 9/13/24.
//

import ARKit
import SwiftData
import SwiftUI

@main
struct PhasorApp: App {
    @StateObject var phasePlayer = PhasePlayerFromUrl()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Projects", systemImage: "folder") {
                    ProjectsView()
                }
            }
        }.modelContainer(for: [
            PhasorProject.self,
            PlaybackSource.self,
            SoundAsset.self,
            SoundEvent.self,
            SoundEventAsset.self,
        ])
    }

    func checkTechnologiesSupported() -> Bool {
        return ARConfiguration.isSupported && phasePlayer.hmm.isDeviceMotionAvailable
    }
}
    
struct ProjectsView : View{
    @Query var projects: [PhasorProject]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Button("Add project") {
            let project = PhasorProject()
            modelContext.insert(project)
        }
        List(projects, id: \.id) { project in
            ShareLink(item: project, preview: SharePreview(project.name))
        }
    }
}
