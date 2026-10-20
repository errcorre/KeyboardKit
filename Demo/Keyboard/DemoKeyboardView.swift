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
                case .character where keyboardContext.keyboardType.isAlphabetic:
                    // Увеличенный шрифт — только для букв алфавитной раскладки,
                    // цифры/символы остаются со стандартным (меньшим) размером.
                    AnyView(params.view.font(.system(size: 25, weight: .regular)))

                case .nextLocale:
                    AnyView(Image(systemName: "globe").font(.system(size: 17)))

                case .space:
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
                    AnyView(params.view)
                }
            },
            buttonView: { params in
                params.view.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            },
            collapsedView: { $0.view },
            emojiKeyboard: { $0.view },
            toolbar: { params in
                // Компактнее, чем дефолтная высота — подбор на глаз,
                // подвинем по следующему скрину, если нужно.
                params.view.frame(maxHeight: 34)
            }
        )
        .padding(.horizontal, 3.5)
    }
}