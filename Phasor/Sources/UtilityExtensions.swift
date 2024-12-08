//
//  UtilityExtensions.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 12/7/24.
//

import Foundation


extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
