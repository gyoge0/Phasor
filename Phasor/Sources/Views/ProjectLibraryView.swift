//
//  ProjectLibraryView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import SwiftData
import SwiftUI

struct ProjectLibraryView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var projects: [PhasorProject]

    @State private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            List(projects) { project in
                NavigationLink(project.name, value: project)
                    .trashSwipe {
                        viewModel.deleteConfirmationComponent
                            .startDeleteAsset(model: project)
                    }
                    .renameSwipe {
                        viewModel.renameModalComponent
                            .startRenameAsset(model: project)
                    }
            }
            .toolbar {
                NewItemButton { viewModel.newItem() }
            }
            .navigationTitle("Projects")
            .overlay {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "tray",
                        description: Text("Create a project to get started")
                    )
                }
            }
            .navigationDestination(for: PhasorProject.self) { project in
                ProjectEditorView(project: project, inPopover: false)
            }
        }
        .errorMessage(errorMessageComponent: viewModel.errorMessageComponent)
        .deleteConfirmation(
            deleteConfirmationComponent: viewModel.deleteConfirmationComponent,
            kind: .alert
        )
        .renameModal(renameModalComponent: viewModel.renameModalComponent)
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .popover(isPresented: $viewModel.newProjectPopoverIsPresented) {
            if let editingProject = viewModel.editingProject {
                NavigationView {
                    ProjectEditorView(
                        project: editingProject,
                        inPopover: true,
                        onDismissPopover: viewModel.dismissProjectPopover
                    )
                }
            }
        }
    }
}

#Preview {
    ProjectLibraryView()
        .modelContainer(for: [
            SoundAsset.self,
            SoundEventAsset.self,
            SoundEvent.self,
            PlaybackSource.self,
            PhasorProject.self,
        ])

}
