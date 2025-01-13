//
//  ExtractedView.swift
//
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import SwiftUI

struct NewItemButton: View {
    var handler: () -> Void = {}

    var body: some View {
        Button(action: handler) {
            Image(systemName: "plus")
        }
    }
}
