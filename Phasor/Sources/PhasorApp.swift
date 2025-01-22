import SwiftData
import SwiftUI

@main
struct PhasorApp: App {
    var body: some Scene {
        DocumentGroup(
            editing: [
                SoundAsset.self,
                SoundEventAsset.self,
                SoundEvent.self,
                PlaybackSource.self,
                PhasorProject.self,
            ],
            contentType: .phasorProject,
            editor: {
                DocumentHomeView()
            },
            prepareDocument: { modelContext in
                let newProject = PhasorProject()
                modelContext.insert(newProject)
                try? modelContext.save()
            }
        )
    }
}
