import KeyboardKit
import SwiftUI

struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    var body: some View {
        KeyboardView(
            layout: .demoLayout(for: state.keyboardContext),
            services: services
        )
        // Системные отступы оригинальной клавиатуры iOS
        .padding(.horizontal, 3)
        .padding(.bottom, 4)
    }
}