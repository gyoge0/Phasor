//
//  PHASEReverbPreset+Names.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import Foundation
import PHASE

extension PHASEReverbPreset {
    // todo: is it best to use None as a default?
    static private let defaultName: String = "None"
    static private let defaultPreset: PHASEReverbPreset = PHASEReverbPreset.none
    
    static let presets: [PHASEReverbPreset] = [
         .cathedral,
         .largeChamber,
         .largeHall,
         .largeHall2,
         .largeRoom,
         .largeRoom2,
         .mediumChamber,
         .mediumHall,
         .mediumHall2,
         .mediumHall3,
         .mediumRoom,
         .none,
         .smallRoom,
    ]
    
    func getName() -> String {
        return switch self {
        case .cathedral: "Cathedral"
        case .largeChamber: "Large Chamber"
        case .largeHall: "Large Hall"
        case .largeHall2: "Large Hall 2"
        case .largeRoom: "Large Room"
        case .largeRoom2: "Large Room 2"
        case .mediumChamber: "Medium Chamber"
        case .mediumHall: "Medium Hall"
        case .mediumHall2: "Medium Hall 2"
        case .mediumHall3: "Medium Hall 3"
        case .mediumRoom: "Medium Room"
        case .none: "None"
        case .smallRoom: "Small Room"
        @unknown default:
            PHASEReverbPreset.defaultName
        }
    }
    
    static func fromName(_ name: String) -> PHASEReverbPreset {
        return switch name {
        case "Cathedral": .cathedral
        case "Large Chamber": .largeChamber
        case "Large Hall": .largeHall
        case "Large Hall 2": .largeHall2
        case "Large Room": .largeRoom
        case "Large Room 2": .largeRoom2
        case "Medium Chamber": .mediumChamber
        case "Medium Hall": .mediumHall
        case "Medium Hall 2": .mediumHall2
        case "Medium Hall 3": .mediumHall3
        case "Medium Room": .mediumRoom
        case "None": .none
        case "Small Room": .smallRoom
        default: PHASEReverbPreset.defaultPreset
        }
    }
    
}
