import KeyboardKit
import SwiftUI

struct DemoKeyboardView: View {

    var services: KeyboardServices
    var state: KeyboardState

    var body: some View {
        KeyboardView(
            services: services,
            // Скрываем громоздкую верхнюю панель подсказок (EmptyView)
            toolbar: { _ in EmptyView() }
        )
        // Только боковые отступы (без верха и низа)
        .padding(.horizontal, 3)
    }
}