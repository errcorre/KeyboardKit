import KeyboardKit
import SwiftUI

struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    @EnvironmentObject var keyboardContext: KeyboardContext

    var body: some View {
        KeyboardView(
            layout: .demoLayout(for: keyboardContext),
            services: services,
            buttonContent: { params in
                if params.item.action == .space {
                    // Пустой пробел, как у системной клавиатуры — без надписи.
                    AnyView(params.view)
                } else {
                    AnyView(params.view)
                }
            },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { params in params.view }
        )
        // Замеренный симметричный внешний отступ клавиатуры: ~6.5pt с каждой стороны.
        .padding(.horizontal, 6.5)
        // Точная стилизация кнопок под замеренные значения оригинала.
        .keyboardButtonStyle { params in
            var style = Keyboard.ButtonStyle.standard(
                for: params.context,
                action: params.item.action,
                isPressed: params.isPressed
            )
            style.cornerRadius = 8   // 24px / 3
            style.font = .init(.system(size: 25, weight: .regular)) // расчёт из x-height "n"
            return style
        }
    }
}