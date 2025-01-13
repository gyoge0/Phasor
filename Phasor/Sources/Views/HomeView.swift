import SwiftUI

public struct HomeView: View {
    public var body: some View {
        TabView {
            Tab("Projects", systemImage: "folder") {
                ProjectLibraryView()
            }
            Tab("Library", systemImage: "waveform") {
                SoundAssetLibraryView()
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            SoundAsset.self,
            SoundEventAsset.self,
            SoundEvent.self,
            PlaybackSource.self,
            PhasorProject.self,
        ])
}
