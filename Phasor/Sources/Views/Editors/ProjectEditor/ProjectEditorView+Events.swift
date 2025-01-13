//
//  ProjectRolloffEditorView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftData
import SwiftUI

extension ProjectEditorView {
    struct EventsSectionView: View {
        @State var project: PhasorProject
        var onNewSoundEventAsset: () -> Void
        var onTrashSwipe: (SoundEventAsset) -> Void
        var onRenameSwipe: (SoundEventAsset) -> Void

        var body: some View {
            Section("Events") {
                Button("New Sound Event") {
                    onNewSoundEventAsset()
                }
                // using a navigation destination modifier here breaks the form's ui
                List(project.soundEventAssets) { item in
                    NavigationLink(
                        item.name,
                        destination: SoundEventAssetEditorView(
                            soundEventAsset: item
                        )
                    )
                    .trashSwipe { onTrashSwipe(item) }
                    .renameSwipe { onRenameSwipe(item) }
                }
            }
        }

    }
}
