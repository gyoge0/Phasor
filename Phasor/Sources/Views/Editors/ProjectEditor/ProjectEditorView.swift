//
//  ProjectEditorView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import PHASE
import SwiftData
import SwiftUI

struct ProjectEditorView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var viewModel = ViewModel()

    @State public var project: PhasorProject

    public var inPopover: Bool = false

    public var onDismissPopover: (Bool) -> Void = { _ in }

    var body: some View {
        Form {
            ReverbSectionView(project: project)

            RolloffSectionView(project: project)

            CullingSectionView(project: project)

            EventsSectionView(
                project: project,
                onNewSoundEventAsset: { viewModel.newSoundEventAsset() },
                onTrashSwipe: { soundEventAsset in
                    viewModel.soundEventAssetDeleteConfirmationComponent
                        .startDeleteAsset(model: soundEventAsset)
                },
                onRenameSwipe: { soundEventAsset in
                    viewModel.soundEventAssetRenameModalComponent
                        .startRenameAsset(model: soundEventAsset)
                }
            )

            EditorRenameView(
                name: project.name,
                onRename: {
                    viewModel.projectRenameModalComponent
                        .startRenameAsset(model: project)
                }
            )
            .renameModal(
                renameModalComponent: viewModel.projectRenameModalComponent
            )

            EditorDeleteView(
                isPresented: !inPopover,
                name: project.name,
                onDelete: {
                    viewModel.projectDeleteConfirmationComponent
                        .startDeleteAsset(model: project)
                }
            )

            if viewModel.technologiesSupported {
                NavigationLink("Play", destination: ProjectArView(project: project))
                    .foregroundStyle(.selection)
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(inPopover ? .inline : .large)
        .toolbar {
            if !inPopover {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: project,
                        preview: SharePreview(
                            project.name,
                            icon: Image("phasor_icon")
                        )
                    )
                }
            }
        }
        .saveCancelToolbar(
            isPresented: inPopover,
            onSave: { onDismissPopover(true) },
            onCancel: { onDismissPopover(false) }
        )
        .errorMessage(
            errorMessageComponent: viewModel.errorMessageComponent
        )
        .deleteConfirmation(
            deleteConfirmationComponent: viewModel.projectDeleteConfirmationComponent,
            kind: .confirmationDialog
        )
        .deleteConfirmation(
            deleteConfirmationComponent: viewModel.soundEventAssetDeleteConfirmationComponent,
            kind: .alert
        )
        .renameModal(
            renameModalComponent: viewModel.projectRenameModalComponent
        )
        .renameModal(
            renameModalComponent: viewModel.soundEventAssetRenameModalComponent
        )
        .sheet(isPresented: $viewModel.newSoundEventAssetPopoverIsPresented) {
            if let editingSoundEventAsset = viewModel.editingSoundEventAsset {
                NavigationView {
                    SoundEventAssetEditorView(
                        soundEventAsset: editingSoundEventAsset,
                        inPopover: true,
                        onDismissPopover: { viewModel.dismissSoundEventAssetPopover(success: $0) }
                    )
                }
                // 0.5 (.medium) is too small
                .presentationDetents([.fraction(0.75), .large])
                // The drag indicator is very close to navigation title
                .padding(.top)
            }
        }
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.project = project
        }
    }
}

#Preview {
    @Previewable
    @State
    var project = PhasorProject()

    ProjectEditorView(project: project)
        .modelContainer(for: [
            SoundAsset.self,
            SoundEventAsset.self,
            SoundEvent.self,
            PlaybackSource.self,
            PhasorProject.self,
        ])

}
