//
//  SoundEventAssetAudioEditorView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import SwiftData
import SwiftUI

extension SoundEventAssetEditorView {
    struct AudioSectionView: View {
        @Environment(\.modelContext) private var modelContext: ModelContext
        @Query private var soundAssets: [SoundAsset]

        @State public var soundEventAsset: SoundEventAsset

        public var soundAssetActionText: String = ""
        public var onSoundAssetAction: (SoundAsset) -> Void = { _ in }

        var body: some View {
            Section("Audio") {
                HStack {
                    Text("Asset")
                    Spacer()
                    Menu {
                        ForEach(soundAssets, id: \.id) { soundAsset in
                            Button {
                                soundEventAsset.soundAsset = soundAsset
                            } label: {
                                HStack {
                                    Text(soundAsset.name)
                                    Spacer()
                                    if soundAsset == soundEventAsset.soundAsset {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        if let soundAsset = soundEventAsset.soundAsset {
                            Text(soundAsset.name)
                                .foregroundStyle(.selection)
                        } else {
                            Text("Choose")
                                .foregroundStyle(.selection)
                        }
                    }
                    .disabled(soundAssets.isEmpty)
                }.foregroundStyle(.foreground)

                if let soundAsset = soundEventAsset.soundAsset {
                    Button(soundAssetActionText) {
                        onSoundAssetAction(soundAsset)
                    }
                    .disabled(soundEventAsset.soundAsset == nil)
                }
            }
        }

    }
}
