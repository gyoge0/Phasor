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
                    ProjectManagerView()
                }
                Tab("Assets", systemImage: "waveform") {
                    SoundAssetManagerView()
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

}
