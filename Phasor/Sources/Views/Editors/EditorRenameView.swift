//
//  EditorRenameView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftUI

struct EditorRenameView: View {
    var name: String
    var onRename: () -> Void

    var body: some View {
        Button(action: onRename) {
            HStack {
                Text("Name")
                Spacer()
                Text(name).foregroundStyle(.selection)
            }
        }.foregroundStyle(.foreground)
    }
}
