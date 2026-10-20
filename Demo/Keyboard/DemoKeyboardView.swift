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
                if case .custom(let name) = params.item.action, name == "change_lang" {
                    AnyView(
                        Image(systemName: "globe")
                            .font(.title3)
                    )
                } else if params.item.action == .space {
                    let isRussian = keyboardContext.locale.identifier.hasPrefix("ru")
                    AnyView(
                        Text(isRussian ? "пробел" : "space")
                            .font(.callout)
                            .opacity(0.6)
                    )
                } else {
                    AnyView(params.view)
                }
            },
            buttonView: { $0.view },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { _ in EmptyView() }
        )
        // Системный отступ по краям
        .padding(.horizontal, 3)
    }
}