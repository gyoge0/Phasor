//
//  SoundAssetLibraryView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import SwiftData
import SwiftUI

struct SoundAssetLibraryView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var soundAssets: [SoundAsset]

    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            List(soundAssets) { soundAsset in
                SoundAssetItemView(
                    soundAsset: soundAsset,
                    playbackState: viewModel.audioPlayer.currentlyPlayingAsset == soundAsset
                        ? viewModel.audioPlayer.playbackState
                        : .stopped,
                    onTap: {
                        viewModel.tapAsset(asset: $0)
                    },
                    onRename: {
                        viewModel.renameModalComponent.startRenameAsset(model: $0)
                    },
                    onDelete: {
                        viewModel.deleteConfirmationComponent.startDeleteAsset(model: $0)
                    }
                )
            }
            .toolbar {
                NewItemButton { viewModel.newItem() }
            }
            .navigationTitle("Library")
            .overlay {
                if soundAssets.isEmpty {
                    ContentUnavailableView(
                        "No Assets",
                        systemImage: "music.note.list",
                        description: Text("Add an asset to get started")
                    )
                }
            }
            .fileImporter(
                isPresented: $viewModel.fileImporterIsPresented,
                allowedContentTypes: [.audio],
                onCompletion: {
                    guard case .success(let result) = $0 else { return }
                    viewModel.importFile(url: result)
                }
            )
        }
        .renameModal(renameModalComponent: viewModel.renameModalComponent)
        .deleteConfirmation(
            deleteConfirmationComponent: viewModel.deleteConfirmationComponent,
            kind: .alert
        )
        .errorMessage(errorMessageComponent: viewModel.errorMessageComponent)
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .onDisappear {
            viewModel.onDisapper()
        }
    }

}

#Preview {
    NavigationView {
        SoundAssetLibraryView()
            .modelContainer(for: [
                SoundAsset.self,
                SoundEventAsset.self,
                SoundEvent.self,
                PlaybackSource.self,
                PhasorProject.self,
            ])
    }
}
