import KeyboardKit
import SwiftUI

struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    // 💡 Благодаря этому SwiftUI сразу реагирует на нажатие Shift, 123 и Глобуса
    @EnvironmentObject var keyboardContext: KeyboardContext

    var body: some View {
        KeyboardView(
            layout: .demoLayout(for: keyboardContext),
            services: services,
            toolbar: { _ in EmptyView() } // полностью убирает панель подсказок
        )
        .padding(.horizontal, 3) // отступы только слева и справа
    }
}