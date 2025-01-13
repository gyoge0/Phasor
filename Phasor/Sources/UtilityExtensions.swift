//
//  UtilityExtensions.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation

extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
