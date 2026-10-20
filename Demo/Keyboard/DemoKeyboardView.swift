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
                            .font(.system(size: 17, weight: .regular))
                    )
                }
                // 2. Подпись на пробеле
                else if params.item.action == .space {
                    let isRussian = keyboardContext.locale.identifier.hasPrefix("ru")
                    AnyView(
                        Text(isRussian ? "пробел" : "space")
                            .font(.system(size: 15, weight: .regular))
                            .opacity(0.6)
                    )
                }
                // 3. Родной тонкий шрифт Apple для букв
                else if case .character(let char) = params.item.action {
                    AnyView(
                        Text(char)
                            .font(.system(size: 22.5, weight: .light, design: .default))
                    )
                } else {
                    AnyView(params.view)
                }
            },
            buttonView: { params in
                // Чистая кнопка без белой мути, со сквирклом и нижней 3D-тенью
                params.view
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .shadow(color: Color.black.opacity(0.35), radius: 0, x: 0, y: 1)
            },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        // Системный отступ по бокам
        .padding(.horizontal, 3)
    }
}