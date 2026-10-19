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
                // Иконка глобуса
                if case .custom(let name) = params.item.action, name == "change_lang" {
                    return AnyView(
                        Image(systemName: "globe")
                            .font(.title3)
                    )
                }

                // Надпись на пробеле
                if params.item.action == .space {
                    let isRussian = keyboardContext.locale.identifier.hasPrefix("ru")
                    return AnyView(
                        Text(isRussian ? "пробел" : "space")
                            .font(.callout)
                            .opacity(0.6)
                    )
                }

                return AnyView(params.view)
            },
            buttonView: { params in
                // Адаптируем скругление под уменьшенную высоту
                params.view
                    .cornerRadius(4.6)
            },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        // Сдвигаем на 4 пикселя вниз
        .padding(.top, 4)
        // Системный отступ по бокам
        .padding(.horizontal, 3)
    }
}