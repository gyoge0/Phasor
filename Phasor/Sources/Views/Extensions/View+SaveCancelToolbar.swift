//
//  View+SaveCancelToolbar.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import SwiftUI

extension View {
    func saveCancelToolbar(
        isPresented: Bool,
        canSave: Bool = true,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        return self.toolbar {
            if isPresented {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
