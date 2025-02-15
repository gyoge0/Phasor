import SwiftUI

public struct HomeView: View {
    @AppStorage("shouldOnboard") private var shouldOnboard = true

    public var body: some View {
        TabView {
            Tab("Projects", systemImage: "folder") {
                ProjectLibraryView()
            }
            Tab("Library", systemImage: "waveform") {
                SoundAssetLibraryView()
            }
        }
        .fullScreenCover(isPresented: $shouldOnboard) {
            OnboardingView(onFinish: { shouldOnboard = false })
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
