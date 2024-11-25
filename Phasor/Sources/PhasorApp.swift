//
//  PhasorApp.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 9/13/24.
//

import SwiftUI
import SwiftData
import ARKit

@main
struct PhasorApp: App {
    @StateObject var phasePlayer = PhasePlayer()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Projects", systemImage: "folder") {
                    if (checkTechnologiesSupported()) {
                        HomeView()
                    } else {
                        NotSupportedView()
                    }
                }
                Tab("Tracks", systemImage: "waveform.path") {
                    AudioModelView()
                }
            }
        }
        .environmentObject(PhasePlayer())
        .modelContainer(for: AudioTrackModel.self)
    }
    
    func checkTechnologiesSupported() -> Bool {
        return ARConfiguration.isSupported && phasePlayer.hmm.isDeviceMotionAvailable
    }
}
