//
//  EspressoArView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 10/7/24.
//

import SwiftUI
import RealityKit
import ARKit
import PHASE


fileprivate func getAudioFile(for track: String) -> String{
    return "espresso_\(track)"
}

fileprivate func getSoundIdentifier(for track: String) -> String {
    return "espressoarview-\(track)"
}

fileprivate func getSoundEventIdentifier(for track: String) -> String {
    return "espressoarview-\(track)Event"
}

fileprivate let locations: [String:simd_float3] = [
    "backings": simd_float3(0.0, 0.0, 1.0),
    "bass": simd_float3(-1.0, 0.0, 0.0),
    "drums": simd_float3(0.0, 0.0, -1.0),
    "guitar_others": simd_float3(1.0, 0.0, 0.0),
    "vocal": simd_float3(0.0, 0.5, 0.0)
]


struct EspressoArConfigView : View {
    @State private var useBackings: Bool = false
    @State private var useBass: Bool = false
    @State private var useDrums: Bool = false
    @State private var useGuitarOthers: Bool = false
    @State private var useVocal: Bool = false
    
    private let tracks = [
        "backings",
        "bass",
        "drums",
        "guitar_others",
        "vocal"
    ]

    struct ConfigSelectionButton : View {
        @State var name: String
        @Binding var isSelected: Bool

        var body: some View {
            Button(action: {
                withAnimation(nil) {
                    isSelected.toggle()
                }
            }) {
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    Image(
                        systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                    )
                        .font(.title)
                }
                    .padding()
                    .background(
                        isSelected
                        ? Color.accentColor
                        : Color(UIColor.secondarySystemBackground)
                    )
                    .foregroundStyle(
                        isSelected
                        ? Color.white
                        : Color.primary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
                .frame(maxWidth: .infinity)
        
        }
    }

    func getSubmitTracks() -> [String] {
        var submitTracks: [String] = []
        
        if useBackings {
            submitTracks = submitTracks + ["backings"]
        }
        if useBass {
            submitTracks = submitTracks + ["bass"]
        }
        if useDrums {
            submitTracks = submitTracks + ["drums"]
        }
        if useGuitarOthers {
            submitTracks = submitTracks + ["guitar_others"]
        }
        if useVocal {
            submitTracks = submitTracks + ["vocal"]
        }
        
        return submitTracks
    }
    
    var body: some View {
        
        VStack {
            ConfigSelectionButton(
                name: "Backings",
                isSelected: $useBackings
            )
            ConfigSelectionButton(
                name: "Bass",
                isSelected: $useBass
            )
            ConfigSelectionButton(
                name: "Drums",
                isSelected: $useDrums
            )
            ConfigSelectionButton(
                name: "Guiter and others",
                isSelected: $useGuitarOthers
            )
            ConfigSelectionButton(
                name: "Vocals",
                isSelected: $useVocal
            )
            Spacer()
            NavigationLink(
                destination: EspressoArView(tracks: getSubmitTracks())
            ) {
                Text("Go")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
            .padding()
            .navigationTitle("Espresso Settings")
    }
}


struct EspressoArView : View {
    var body: some View {
        let delegate = EspressoArSessionDelegate(player: player)
        
        let arViewRepresentable = EspressoArViewRepresentable(delegate: delegate, tracks: tracks)
        
        arViewRepresentable
            .edgesIgnoringSafeArea(.all) // Makes ARView fill the entire screen
            .onAppear() {
                try! initPlayerSources()
                
                for (track, soundSource) in soundSources {
                    let soundEvent = try! player.createSoundEvent(
                        source: soundSource,
                        soundeEventAssetIdentifier: getSoundEventIdentifier(for: track)
                    )
                    
                    soundEvent.start()
                }
            }
            .onDisappear() {
                deinitPlayerSources()
            }
    }
    
    let tracks: [String]
    @State var soundSources: [String:PHASESource] = [:]
    @EnvironmentObject var player: PhasePlayer
    
    private func initPlayerSources() throws {
        for track in tracks {
            // Retrieve the URL to an Audio File stored in our Application Bundle.
            print(getAudioFile(for: track))
            let audioFileUrl = Bundle.main.url(
                forResource: getAudioFile(for: track),
                withExtension: "wav"
            )!
            
            // Register the Audio File at the URL.
            try player.addSoundAsset(
                url: audioFileUrl,
                identifier: getSoundIdentifier(for: track)
            )
            
            try player.createSoundEventAsset(
                soundEventAssetIdentifier: getSoundEventIdentifier(for: track),
                soundAssetIdentifier: getSoundIdentifier(for: track),
                playbackMode: .looping,
                calibrationLevel: 0.0,
                cullOption: .sleepWakeAtRealtimeOffset
            )
            
            let location = locations[track]!
            let soundSource = try player.createPlaybackSource(transform: simd_float4x4(
                1.0, 0.0, 0.0, location.x,
                0.0, 1.0, 0.0, location.y,
                0.0, 0.0, 1.0, location.z,
                0.0, 0.0, 0.0, 1.0
            ));
            soundSources[track] = soundSource
        }
        
        try! player.engine.start()
    }
    
    private func deinitPlayerSources() {
        for track in tracks {
            player.removeAsset(identifier: getSoundIdentifier(for: track))
            player.removeAsset(identifier: getSoundEventIdentifier(for: track))
        }
    }
}


struct EspressoArViewRepresentable: UIViewRepresentable {
    let delegate: EspressoArSessionDelegate
    let tracks: [String]
    
    init(delegate: EspressoArSessionDelegate, tracks: [String]) {
        self.delegate = delegate
        self.tracks = tracks
    }
    
    func makeUIView(context: Context) -> some UIView {
        let arView = EspressoArARView()
        arView.placeOrbs(tracks: tracks)
        
        arView.session.delegate = delegate
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}


class EspressoArSessionDelegate: NSObject, ARSessionDelegate {
    let player: PhasePlayer
    
    init(player: PhasePlayer) {
        self.player = player
    }
    
    var count = 0
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let transform =  session.currentFrame?.camera.transform else { return }
        if count == 0 {
            player.listener.transform = transform
            count = 30
        } else {
            count = count - 1
        }
    }
}


class EspressoArARView : ARView {
    required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    dynamic required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    func placeOrbs(tracks: [String]) {
        for track in tracks {
            let location = locations[track]!
            let sphere = MeshResource.generateSphere(radius: 0.2)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let orb = ModelEntity(mesh: sphere, materials: [material])
            
            let anchor = AnchorEntity(world: .init(x: location.x, y: location.y, z: location.z))
            anchor.addChild(orb)
            
            scene.addAnchor(anchor)
        }
    }
}


#Preview {
    NavigationView {
        EspressoArConfigView()
            .environmentObject(PhasePlayer())
    }
}
