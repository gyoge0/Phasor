//
//  ContentView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 9/13/24.
//

import SwiftUI
import PHASE
import CoreMotion

fileprivate let drumsSoundIdentifier = "drumbeatview-drums"
fileprivate let drumsSoundEventIdentifier = "drumbeatview-drumsEvent"

struct DrumBeatView: View {
    @EnvironmentObject var player: PhasePlayer
    
    @State var leftSource: PHASESource!
    @State var rightSource: PHASESource!
    @State var frontSource: PHASESource!
    @State var aboveSource: PHASESource!
    
    var body: some View {
        VStack {
            Button(action: { playSound(source: rightSource) }) {
                Text("Play Sound Right")
            }
            Button(action: { playSound(source: leftSource) }) {
                Text("Play Sound Left")
            }
            Button(action: { playSound(source: frontSource) }) {
                Text("Play Sound Front")
            }
            Button(action: { playSound(source: aboveSource) }) {
                Text("Play Sound Above")
            }
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .onAppear {
            try! initPlayerSources()
        }
        .onDisappear {
            deinitPlayerSources()
        }
        .navigationTitle("Drum Beat")
    }
    
    
    private func initPlayerSources() throws {
        // Retrieve the URL to an Audio File stored in our Application Bundle.
        let audioFileUrl = Bundle.main.url(forResource: "drums", withExtension: "wav")!
        
        // Register the Audio File at the URL.
        try player.addSoundAsset(url: audioFileUrl, identifier: drumsSoundIdentifier)
        
        try player.createSoundEventAsset(
            soundEventAssetIdentifier: drumsSoundEventIdentifier,
            soundAssetIdentifier: drumsSoundIdentifier,
            playbackMode: .oneShot,
            calibrationLevel: 0.0,
            cullOption: .sleepWakeAtRealtimeOffset
        )
        
        leftSource = try player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, -2.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        rightSource = try player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, 2.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        frontSource = try player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, -2.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        aboveSource = try player.createPlaybackSource(transform: simd_float4x4(
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 2.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ));
        
        try! player.engine.start()
    }
    
    private func deinitPlayerSources() {
        player.removeAsset(identifier: drumsSoundIdentifier)
        player.removeAsset(identifier: drumsSoundEventIdentifier)
    }
    
    
    
    func playSound(source: PHASESource) {
        let soundEvent = try! player.createSoundEvent(source: source, soundEventAssetIdentifier: drumsSoundEventIdentifier)
        
        
        soundEvent.start()
    }
}

#Preview {
    NavigationView {
        DrumBeatView()
            .environmentObject(PhasePlayer())
    }
}
