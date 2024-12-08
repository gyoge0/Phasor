//
//  PlaybackSource.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/6/24.
//


import Foundation
import PHASE
import SwiftData
import SwiftUI
import MetaCodable

/// A point in space from which audio can be played.
@Codable
@Inherits(decodable: false, encodable: false)
@Model
class PlaybackSource {
    @Attribute(.unique)
    var id: UUID = UUID()

    var rawTransform: [Float]! = nil
    
    @IgnoreCoding
    var project: PhasorProject? = nil

    @Transient
    var transform: simd_float4x4 {
        get {
            // swift-format-ignore
            return simd_float4x4(
                rawTransform[0],  rawTransform[1],  rawTransform[2],  rawTransform[3],
                rawTransform[4],  rawTransform[5],  rawTransform[6],  rawTransform[7],
                rawTransform[8],  rawTransform[9],  rawTransform[10], rawTransform[11],
                rawTransform[12], rawTransform[13], rawTransform[14], rawTransform[15]
            )
        }
        set(newValue) {
            // swift-format-ignore
            rawTransform = [
                newValue.columns.0.x, newValue.columns.1.x, newValue.columns.2.x, newValue.columns.3.x,
                newValue.columns.0.y, newValue.columns.1.y, newValue.columns.2.y, newValue.columns.3.y,
                newValue.columns.0.z, newValue.columns.1.z, newValue.columns.2.z, newValue.columns.3.z,
                newValue.columns.0.w, newValue.columns.1.w, newValue.columns.2.w, newValue.columns.3.w
            ]
        }
    }

    init(transform: simd_float4x4) {
        self.transform = transform
    }
}
