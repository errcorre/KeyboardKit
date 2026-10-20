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
                switch params.item.action {
                case .character:
                    // Шрифт 25pt — только для букв, не для иконок Shift/Backspace.
                    AnyView(params.view.font(.system(size: 25, weight: .regular)))

                case .nextLocale:
                    // Глобус вместо текстового "EN"/"RU" по умолчанию.
                    AnyView(Image(systemName: "globe").font(.system(size: 17)))

                case .space:
                    // Пустой пробел + маленькая подпись локали в правом нижнем углу,
                    // как у системной клавиатуры.
                    AnyView(
                        params.view.overlay(alignment: .bottomTrailing) {
                            Text(keyboardContext.locale.identifier.hasPrefix("ru") ? "ру" : "A")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 6)
                                .padding(.bottom, 4)
                        }
                    )

                default:
                    // Shift, Backspace, 123 и всё остальное — без изменений.
                    AnyView(params.view)
                }
            },
            buttonView: { params in
                params.view.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { params in params.view }
        )
        .padding(.horizontal, 6.5)
    }
}