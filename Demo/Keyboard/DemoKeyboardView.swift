import KeyboardKit
import SwiftUI

struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    // 💡 Реагирует на нажатие Shift, 123 и смену языка через глобус
    @EnvironmentObject var keyboardContext: KeyboardContext

    var body: some View {
        KeyboardView(
            layout: .demoLayout(for: keyboardContext),
            services: services,
            buttonContent: { params in
                // Отрисовка системной иконки глобуса для нашей кастомной кнопки
                if case .custom(let name) = params.action, name == "change_lang" {
                    Image(systemName: "globe")
                        .font(.title3)
                } else {
                    params.view
                }
            },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() } // Скрываем громоздкую верхнюю панель подсказок
        )
        // Системный отступ только слева и справа
        .padding(.horizontal, 3)
    }
}