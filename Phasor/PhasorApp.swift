//
//  PhasorApp.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 9/13/24.
//

import SwiftUI
import ARKit

@main
struct PhasorApp: App {
    var phasePlayer = PhasePlayer()
    
    var body: some Scene {
        WindowGroup {
            if (checkTechnologiesSupported()) {
                HomeView()
            } else {
                NotSupportedView()
            }
        }
        .environmentObject(PhasePlayer())
    }
    
    func checkTechnologiesSupported() -> Bool {
        return ARConfiguration.isSupported && phasePlayer.hmm.isDeviceMotionAvailable
    }
}
