//
//  ProjectEditorView+Reverb.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import Foundation
import PHASE
import SwiftUI

extension ProjectEditorView {
    struct ReverbSectionView: View {
        @State var project: PhasorProject

        var body: some View {
            Section("Reverb") {
                Picker("Reverb Preset", selection: $project.reverbPreset) {
                    ForEach(PHASEReverbPreset.presets, id: \.self) { preset in
                        Text(preset.getName()).tag(preset)
                    }
                }
            }
        }

    }
}
