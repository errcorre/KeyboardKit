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
                    return AnyView(
                        Image(systemName: "globe")
                            .font(.title3)
                    )
                }
                
                // 2. Нативная надпись на пробеле в зависимости от языка
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
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        .padding(.horizontal, 3)
    }
}