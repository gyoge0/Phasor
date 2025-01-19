import SwiftData
import SwiftUI

@main
struct PhasorApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [
            SoundAsset.self,
            SoundEventAsset.self,
            SoundEvent.self,
            PlaybackSource.self,
            PhasorProject.self,
        ])
    }
}
