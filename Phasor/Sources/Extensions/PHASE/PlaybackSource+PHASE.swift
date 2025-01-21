//
//  PlaybackSource+PHASE.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import PHASE

extension PlaybackSource {
    public var transform: simd_float4x4 {
        get {
            // swift-format-ignore
            return simd_float4x4(
                rows: [
                    SIMD4(rawTransform[0],  rawTransform[1],  rawTransform[2],  rawTransform[3]),
                    SIMD4(rawTransform[4],  rawTransform[5],  rawTransform[6],  rawTransform[7]),
                    SIMD4(rawTransform[8],  rawTransform[9],  rawTransform[10], rawTransform[11]),
                    SIMD4(rawTransform[12], rawTransform[13], rawTransform[14], rawTransform[15])
                ]
            )
        }
        set(newValue) {
            // swift-format-ignore
            rawTransform = simd4x4ToArray(newValue)
        }
    }

    public convenience init(transform: simd_float4x4) {
        self.init(rawTransform: simd4x4ToArray(transform))
    }
}

public func simd4x4ToArray(_ transform: simd_float4x4) -> [Float] {

    // swift-format-ignore
    return [
        transform.columns.0.x, transform.columns.1.x, transform.columns.2.x, transform.columns.3.x,
        transform.columns.0.y, transform.columns.1.y, transform.columns.2.y, transform.columns.3.y,
        transform.columns.0.z, transform.columns.1.z, transform.columns.2.z, transform.columns.3.z,
        transform.columns.0.w, transform.columns.1.w, transform.columns.2.w, transform.columns.3.w
    ]
}
