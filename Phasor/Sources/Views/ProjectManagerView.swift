//
//  ProjectsView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import SwiftUI
import SwiftData

struct ProjectManagerView : View {
    @Query var projects: [PhasorProject]
    @Environment(\.modelContext) var modelContext
    
    @State var renameModalShown: Bool = false
    @State var editedProjectName: String = ""
    @State var selectedProjectForRename: PhasorProject? = nil
    @State var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(projects, id: \.id) { project in
                ProjectItem(project: project, renameAction: {
                    selectedProjectForRename = project
                    editedProjectName = project.name
                    renameModalShown = true
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        modelContext.insert(PhasorProject(name: "New Project"))
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .overlay {
                if projects.isEmpty {
                    ContentUnavailableView.init(
                        "No Projects",
                        systemImage: "tray",
                        description: Text("Create a project to get started")
                    )
                }
            }
            .alert(
                "Rename",
                isPresented: $renameModalShown,
                actions: {
                    TextField("Name", text: $editedProjectName)
                    Button("Cancel") {
                        renameModalShown = false
                    }
                    Button("Save") {
                        renameModalShown = false
                        selectedProjectForRename?.name = editedProjectName
                    }.disabled(editedProjectName.isEmpty)
                }
            )
            .navigationTitle("Projects")
        }
    }
}
