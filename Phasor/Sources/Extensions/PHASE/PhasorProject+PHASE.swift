//
//  PhasorProject+PHASE.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import PHASE

extension PhasorProject {

    public var reverbPreset: PHASEReverbPreset {
        get { return PHASEReverbPreset(rawValue: rawReverbPreset)! }
        set(newValue) { rawReverbPreset = newValue.rawValue }
    }

}
