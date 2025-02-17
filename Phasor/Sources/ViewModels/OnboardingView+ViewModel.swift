//
//  OnboardingView+ViewModel.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 2/14/25.
//

import Foundation
import PHASE
import SwiftData

private func getAudioFile(for track: String) -> String {
    return "espresso_\(track)"
}

private let locations: [String: simd_float3] = [
    "backings": simd_float3(0.0, 0.0, 1.0),
    "bass": simd_float3(-1.0, 0.0, 0.0),
    "drums": simd_float3(0.0, 0.0, -1.0),
    "guitar_others": simd_float3(1.0, 0.0, 0.0),
    "vocal": simd_float3(0.0, 0.5, 0.0),
]

private let tracks = [
    "backings",
    "bass",
    "drums",
    "guitar_others",
    "vocal",
]

private func getName(for track: String) -> String {
    // kind of cheeky since we know theres only 1 _
    let capitalized = track.replacingOccurrences(of: "_", with: " + ")
    return "Demo - Espresso \(capitalized)"
}

extension OnboardingView {
    @Observable
    class ViewModel {
        var modelContext: ModelContext! = nil {
            didSet {
                modelContextComponent.modelContext = modelContext
            }
        }

        public var errorMessageComponent: ErrorMessageComponent
        public var modelContextComponent: ModelContextComponent
        public var fileImporterComponent: FileImporterComponent

        init() {
            // construct dependency graph
            let errorMessageComponent = ErrorMessageComponent()
            let modelContextComponent = ModelContextComponent(
                errorMessageComponent: errorMessageComponent
            )
            let fileImporterComponent = FileImporterComponent(
                modelContextComponent: modelContextComponent,
                errorMessageComponent: errorMessageComponent
            )

            // assign all at once
            self.errorMessageComponent = errorMessageComponent
            self.modelContextComponent = modelContextComponent
            self.fileImporterComponent = fileImporterComponent
        }

        func loadDemoProject() async {
            var soundAssets: [SoundAsset] = []
            var soundEventAssets: [SoundEventAsset] = []
            var playbackSources: [PlaybackSource] = []
            var soundEvents: [SoundEvent] = []

            for track in tracks {
                let audioFileUrl = Bundle.main.url(
                    forResource: getAudioFile(for: track),
                    withExtension: "m4a"
                )!
                let location = locations[track]!

                guard
                    let soundAsset = fileImporterComponent.importFile(
                        url: audioFileUrl,
                        name: getName(for: track)
                    )
                else {
                    modelContext.rollback()
                    return
                }
                let soundEventAsset = SoundEventAsset(
                    name: getName(for: track),
                    soundAsset: soundAsset
                )
                // swift-format-ignore
                let playbackSource = PlaybackSource(
                    transform: simd_float4x4(
                        1.0, 0.0, 0.0, location.x,
                        0.0, 1.0, 0.0, location.y,
                        0.0, 0.0, 1.0, location.z,
                        0.0, 0.0, 0.0, 1.0
                    )
                )
                let soundEvent = SoundEvent(
                    soundEventAsset: soundEventAsset,
                    playbackSource: playbackSource
                )

                soundAssets.append(soundAsset)
                soundEventAssets.append(soundEventAsset)
                playbackSources.append(playbackSource)
                soundEvents.append(soundEvent)
            }

            let project = PhasorProject(name: "Demo Project - Espresso")

            soundEventAssets.forEach { project.soundEventAssets.append($0) }
            soundEvents.forEach { project.soundEvents.append($0) }

            soundAssets.forEach(modelContext.insert)
            soundEventAssets.forEach(modelContext.insert)
            playbackSources.forEach(modelContext.insert)
            soundEvents.forEach(modelContext.insert)
            modelContext.insert(project)
            _ = modelContextComponent.trySaveModelContext(withMessage: "Something went wrong.")
        }

    }
}
