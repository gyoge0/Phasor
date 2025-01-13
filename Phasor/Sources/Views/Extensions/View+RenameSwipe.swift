//
//  View+TrashSwipe.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftUI

extension View {
    func renameSwipe(
        onRename: @escaping () -> Void
    ) -> some View {
        return self.swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: onRename) {
                Image(systemName: "pencil")
                    .tint(.yellow)
            }
        }
    }
}
