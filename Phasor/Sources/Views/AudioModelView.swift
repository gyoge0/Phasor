//
//  AudioModelView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 11/22/24.
//

import SwiftUI
import SwiftData
import AVFoundation

struct AudioModelView: View {
    @Query var audioTracks: [AudioTrackModel]
    @State var filePickerShown: Bool = false
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @State var selectedTrack: AudioTrackModel?
    @State var modalShown: Bool = false
    @State var modalName: String = ""
    
    var avPlayer = AVPlayer()
    
    var body: some View {
        NavigationStack {
            List(audioTracks, id: \.id) { audioTrack in
                Button(audioTrack.name) {
                    selectedTrack = audioTrack
                    modalName = audioTrack.name
                    modalShown = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { filePickerShown = true }) {
                        Image(systemName: "waveform.path.badge.plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $filePickerShown,
                allowedContentTypes: [.audio],
                onCompletion: { result in
                    guard case .success(let url) = result else { return }
                    guard let audioData = try? Data(contentsOf: url) else { return }
                    
                    modelContext.insert(AudioTrackModel(
                        name: url.lastPathComponent,
                        trackData: audioData
                    ))
                    filePickerShown = false
                }
            )
            .overlay {
                if audioTracks.isEmpty {
                    ContentUnavailableView.init("No tracks", systemImage: "tray", description: Text("Add a track to get started"))
                }
            }.alert("Enter a name", isPresented: $modalShown) {
                TextField("Name", text: $modalName)
                Button("Save") {
                    modalShown = false
                    selectedTrack?.name = modalName
                }.disabled(modalName.isEmpty)
            }
        }
    }
}



#Preview {
    AudioModelView()
        .modelContainer(for: [
            AudioTrackModel.self
        ])
}
