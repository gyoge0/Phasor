//
//  ProjectRolloffEditorView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftUI

extension ProjectEditorView {
    struct RolloffSectionView: View {
        @State var project: PhasorProject

        var body: some View {
            Section("Rolloff") {
                HStack {
                    Text("Rolloff Strength")
                    Spacer()
                    Text(project.rolloffFactor.rounded(to: 2).description)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $project.rolloffFactor, in: 0...2, step: 0.01)
            }
        }

    }
}
