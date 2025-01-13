//
//  SoundEventAssetPlaybackSettingsEditorView.swift
//
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//
import Foundation
import PHASE
import SwiftUI

extension SoundEventAssetEditorView {
    struct PlaybackSettingsSectionView: View {
        @State public var soundEventAsset: SoundEventAsset

        var body: some View {
            Section("Playback Setings") {
                Toggle(
                    isOn: Binding(
                        get: { soundEventAsset.playbackMode == .looping },
                        set: { soundEventAsset.playbackMode = $0 ? .looping : .oneShot }
                    )
                ) {
                    Text("Loop Audio")
                }

                Picker("Culling Mode", selection: $soundEventAsset.cullOption) {
                    ForEach(PHASECullOption.options, id: \.self) { cullOption in
                        Text(cullOption.getName()).tag(cullOption)
                    }
                }

                HStack {
                    Text("Calibration Level")
                    Spacer()
                    //                    Text(soundEventAsset.calibrationLevel.rounded(to: 2).description)
                    //                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $soundEventAsset.calibrationLevel,
                    in: 0...2,
                    step: 0.01
                )
            }
        }

    }
}
