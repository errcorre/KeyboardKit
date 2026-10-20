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
                // Иконка глобуса на кастомной кнопке переключения языка.
                if case .custom(let name) = params.item.action, name == "change_lang" {
                    AnyView(
                        Image(systemName: "globe")
                            .font(.system(size: 17))
                    )
                }
                // Нативная надпись на пробеле в зависимости от языка.
                else if params.item.action == .space {
                    let isRussian = keyboardContext.locale.identifier.hasPrefix("ru")
                    AnyView(
                        Text(isRussian ? "пробел" : "space")
                            .font(.callout)
                    )
                }
                // Всё остальное — стандартный рендер библиотеки, без
                // кастомного шрифта. Он сам адаптирует размер под кнопку
                // и под устройство так же, как это делает системная клавиатура.
                else {
                    AnyView(params.view)
                }
            },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        // Никакого дополнительного .padding(.horizontal, ...) — системные
        // отступы уже заложены внутри .standard(for:) и buttonView.
    }
}