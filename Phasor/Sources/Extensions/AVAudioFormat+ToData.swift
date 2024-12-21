//
//  AVAudioFormat+ToData.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/13/24.
//

import AVFoundation
import Foundation

extension AVAudioFormat {
    func encode() -> AVAudioFormatEncoded {
        return AVAudioFormatEncoded(
            commonFormat: commonFormat.rawValue,
            sampleRate: sampleRate,
            channels: channelCount,
            interleaved: isInterleaved
        )
    }

    static func decode(from encoded: AVAudioFormatEncoded) -> AVAudioFormat {
        return AVAudioFormat(
            commonFormat: AVAudioCommonFormat(rawValue: encoded.commonFormat)!,
            sampleRate: encoded.sampleRate,
            channels: encoded.channels,
            interleaved: encoded.interleaved
        )!
    }
}

struct AVAudioFormatEncoded: Codable {
    var commonFormat: UInt
    var sampleRate: Double
    var channels: AVAudioChannelCount
    var interleaved: Bool
}
