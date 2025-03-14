import SwiftUI

public struct HomeView: View {
    @AppStorage("shouldOnboard") private var shouldOnboard = true
    @State private var shakeReceived = false

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
        .onReceive(
            NotificationCenter.default.publisher(
                for: .deviceDidShakeNotification
            )
        ) { _ in
            shakeReceived = true
        }
        .alert("Reset Demo?", isPresented: $shakeReceived) {
            Button("Reset", role: .destructive) {
                shakeReceived = false
                shouldOnboard = true
            }
            Button("Cancel", role: .cancel) {
                shakeReceived = false
            }
        }
    }
}

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name(
        "com.gyoge.Phasor.deviceDidShakeNotification"
    )
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)

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
