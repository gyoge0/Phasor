//
//  EditorDeleteView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftUI

struct EditorDeleteView: View {
    var isPresented: Bool
    var name: String
    var onDelete: () -> Void

    var body: some View {
        if isPresented {
            Button(role: .destructive, action: onDelete) {
                Text("Delete \(name)")
            }
        }
    }

}
