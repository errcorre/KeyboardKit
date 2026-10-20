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
                // 1. Иконка глобуса
                if case .custom(let name) = params.item.action, name == "change_lang" {
                    AnyView(
                        Image(systemName: "globe")
                            .font(.system(size: 17))
                    )
                }
                // 2. Нативная надпись на пробеле
                else if params.item.action == .space {
                    let isRussian = keyboardContext.locale.identifier.hasPrefix("ru")
                    AnyView(
                        Text(isRussian ? "пробел" : "space")
                            .font(.callout)
                    )
                }
                // 3. Аккуратный уменьшенный шрифт (22 pt)
                else if case .character(let char) = params.item.action {
                    AnyView(
                        Text(char)
                            .font(.system(size: 22, weight: .regular))
                    )
                } else {
                    AnyView(params.view)
                }
            },
            buttonView: { params in
                // Ровно 8 pt (24 px из твоего замера) со сглаживанием Apple
                params.view
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        // Системный отступ по бокам
        .padding(.horizontal, 3)
    }
}