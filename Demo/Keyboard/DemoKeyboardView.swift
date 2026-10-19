//
//  DemoKeyboardView.swift
//  KeyboardPro
//

import KeyboardKit
import SwiftUI

/// Чистая нативная клавиатура Apple с системным AutocompleteToolbar
struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    var body: some View {
        KeyboardView(
            services: services
        )
    }
}