//
//  View+ErrorMessage.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/11/25.
//

import Foundation
import SwiftUI

struct ErrorMessage: ViewModifier {
    @State public var errorMessageComponent: ErrorMessageComponent

    func body(content: Content) -> some View {
        content.alert("Error", isPresented: $errorMessageComponent.isPresented) {
            if let errorMessage = errorMessageComponent.message {
                Text(errorMessage)
            }
        }
    }
}

extension View {
    func errorMessage(errorMessageComponent: ErrorMessageComponent) -> some View {
        return self.modifier(ErrorMessage(errorMessageComponent: errorMessageComponent))
    }
}
