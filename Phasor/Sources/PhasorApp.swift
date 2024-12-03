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
    @StateObject var phasePlayer = PhasePlayerFromUrl()
    
    var body: some Scene {
        DocumentGroup(
            editing: PhasorSubProject.self,
            contentType: .phasorProject
        ) {
            MyView()
        }
    }
    
    func checkTechnologiesSupported() -> Bool {
        return ARConfiguration.isSupported && phasePlayer.hmm.isDeviceMotionAvailable
    }
}

struct MyView: View {
    @Environment(\.modelContext) var modelContext;
    
    @Query var projects: [PhasorSubProject]
    @State var toggle: Bool = false
    
    var body: some View {
        TabView {
            Tab("Projects", systemImage: "folder") {
                Text("test")
            }
            Tab("Tracks", systemImage: "waveform.path") {
                AudioModelView()
            }
        }
    }
}

extension UTType {
    static var phasorProject = UTType(
        exportedAs: "com.gyoge.phasor.phasorproject",
        conformingTo: .package
    )
}
