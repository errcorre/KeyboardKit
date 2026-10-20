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
                AnyView(params.view.font(.system(size: 25, weight: .regular)))
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