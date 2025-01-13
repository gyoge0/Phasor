//
//  ProjectRolloffEditorView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftUI

extension ProjectEditorView {
    struct CullingSectionView: View {
        @State var project: PhasorProject

        var body: some View {
            Section("Culling") {
                HStack {
                    Text("Cull Distance (m)")
                    Spacer()
                    Text(project.cullDistance.rounded(to: 1).description)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $project.cullDistance, in: 1...10, step: 0.1)
            }
        }

    }
}
