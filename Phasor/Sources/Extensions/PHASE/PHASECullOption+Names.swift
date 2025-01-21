//
//  PHASECullOption+Names.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import PHASE

extension PHASECullOption {
    // todo: is it best to use None as a default?
    static private let defaultName: String = "Real Time"
    static private let defaultOption: PHASECullOption = .sleepWakeAtRealtimeOffset

    static let options: [PHASECullOption] = [
        .doNotCull,
        .sleepWakeAtZero,
        .sleepWakeAtRandomOffset,
        .sleepWakeAtRealtimeOffset,
        .terminate,
    ]

    func getName() -> String {
        return switch self {
        case .doNotCull: "None"
        case .sleepWakeAtZero: "Restart"
        case .sleepWakeAtRandomOffset: "Random Offset"
        case .sleepWakeAtRealtimeOffset: "Real Time"
        case .terminate: "Stop Playback"
        @unknown default:
            PHASECullOption.defaultName
        }
    }

    static func fromName(_ name: String) -> PHASECullOption {
        return switch name {
        case "None": .doNotCull
        case "Restart": .sleepWakeAtZero
        case "Random Offset": .sleepWakeAtRandomOffset
        case "Real Time": .sleepWakeAtRealtimeOffset
        case "Stop Playback": .terminate
        default: PHASECullOption.defaultOption
        }
    }

}
