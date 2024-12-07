//
//  ProjectsView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import SwiftUI
import SwiftData

struct ProjectsView : View {
    @Query var projects: [PhasorProject]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Button("Add project") {
            let project = PhasorProject()
            modelContext.insert(project)
        }
        List(projects, id: \.id) { project in
            ShareLink(item: project, preview: SharePreview(project.name))
        }
    }
}
