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
                // 3. Все буквы рендерит сам KeyboardKit по родным стандартам Apple
                else {
                    AnyView(params.view)
                }
            },
            buttonView: { params in
                // Нативное скругление-сквиркл Apple + нижняя 3D-тень
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