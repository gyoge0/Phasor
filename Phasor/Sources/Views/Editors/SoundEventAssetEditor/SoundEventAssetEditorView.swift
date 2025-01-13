//
//  SoundEventAssetEditorView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import PHASE
import SwiftData
import SwiftUI

struct SoundEventAssetEditorView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State public var soundEventAsset: SoundEventAsset
    public var inPopover: Bool = false

    @State private var viewModel = ViewModel()

    public var onDismissPopover: (Bool) -> Void = { _ in }

    var body: some View {
        Form {
            PlaybackSettingsSectionView(
                soundEventAsset: soundEventAsset
            )

            AudioSectionView(
                soundEventAsset: soundEventAsset,
                soundAssetActionText: viewModel.playbackState == .playing
                    ? "Pause" : "Play",
                onSoundAssetAction: {
                    viewModel.handleAsset(soundAsset: $0)
                }
            )

            EditorRenameView(
                name: soundEventAsset.name,
                onRename: {
                    viewModel.renameModalComponent
                        .startRenameAsset(model: soundEventAsset)
                }
            )
            .renameModal(
                renameModalComponent: viewModel.renameModalComponent
            )

            EditorDeleteView(
                isPresented: !inPopover,
                name: soundEventAsset.name,
                onDelete: {
                    viewModel.deleteConfirmationComponent
                        .startDeleteAsset(model: soundEventAsset)
                }
            )

        }
        .navigationTitle(soundEventAsset.name)
        .navigationBarTitleDisplayMode(inPopover ? .inline : .large)
        .saveCancelToolbar(
            isPresented: inPopover,
            canSave: soundEventAsset.soundAsset != nil,
            onSave: { onDismissPopover(true) },
            onCancel: { onDismissPopover(false) }
        )
        .modifier(
            ErrorMessage(
                errorMessageComponent: viewModel.errorMessageComponent
            )
        )
        .deleteConfirmation(
            deleteConfirmationComponent: viewModel.deleteConfirmationComponent,
            kind: .confirmationDialog
        )
        .renameModal(
            renameModalComponent: viewModel.renameModalComponent
        )
        .onAppear {
            viewModel.modelContextComponent.modelContext = modelContext
            viewModel.soundEventAsset = soundEventAsset
        }
        .onDisappear {
            viewModel.onDisapper()
        }
    }
}

#Preview {
    SoundEventAssetEditorView(soundEventAsset: SoundEventAsset())
        .modelContainer(for: [
            SoundAsset.self,
            SoundEventAsset.self,
            SoundEvent.self,
            PlaybackSource.self,
            PhasorProject.self,
        ])
}
