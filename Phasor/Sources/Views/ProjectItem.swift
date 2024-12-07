//
//  ProjectItem.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import SwiftUI
import SwiftData

struct ProjectItem: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @State var project: PhasorProject
    var renameAction: () -> Void
    
    var body: some View {
        NavigationLink(project.name, destination: ProjectManagerView())
        .foregroundStyle(.foreground)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(project)
            } label: {
                Image(systemName: "trash")
            }
            Button(
                action: renameAction,
                label: {
                    Image(systemName: "pencil")
                }
            )
            .tint(.yellow)
        }
    }
}

