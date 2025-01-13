//
//  View+TrashSwipe.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/12/25.
//

import SwiftUI

extension View {
    func trashSwipe(
        onDelete: @escaping () -> Void
    ) -> some View {
        return self.swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // we can't do roll: .destructive here since that will remove this
            // item from the UI even if we cancel the delete
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
    }
}
