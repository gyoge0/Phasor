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
            if (checkTechnologiesSupported()) {
                HomeView()
            } else {
                NotSupportedView()
            }
        }
        .environmentObject(PhasePlayer())
        .modelContainer(for: AudioTrackModel.self)
    }
    
    func checkTechnologiesSupported() -> Bool {
        return ARConfiguration.isSupported && phasePlayer.hmm.isDeviceMotionAvailable
    }
}
