//
//  DemoKeyboardView.swift
//  KeyboardPro
//

import KeyboardKit
import SwiftUI

/// Чистая нативная клавиатура в стиле Apple с системным AutocompleteToolbar
struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    var body: some View {
        KeyboardView(
            state: state,
            services: services,
            buttonContent: { $0.view },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { $0.view } // <-- Системная строка автокомплита (i | the | i'm)
        )
    }
}