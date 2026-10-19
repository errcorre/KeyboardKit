import KeyboardKit
import KeyboardKitHostPlugin
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {

    deinit {
        NSLog("__DEINIT__")
    }

    override func viewWillSetupKeyboardKit() {
        // Принудительно настраиваем стейт и обработчики, не ожидая Pro-лицензии
        setupDemoServices()
        setupDemoState()

        setupKeyboardKit(
            for: .keyboardKitDemo,
            hostApplicationResolver: pluginHostApplicationResolver
        ) { _ in }
    }

    override func viewWillSetupKeyboardView() {
        setupKeyboardView { controller in
            DemoKeyboardView(
                services: controller.services,
                state: controller.state
            )
        }
    }
}

private extension KeyboardViewController {

    func setupDemoServices() {
        DemoKeyboardActionHandler.inputController = self
        services.actionHandler = DemoKeyboardActionHandler(
            controller: self
        )
    }

    func setupDemoState() {
        // Доступные локали: Английский и Русский
        state.keyboardContext.locales = [
            Locale(identifier: "en"),
            Locale(identifier: "ru")
        ]
        state.keyboardContext.locale = Locale(identifier: "en")
        state.keyboardContext.localePresentationLocale = .current

        state.keyboardContext.autocapitalizationType = nil

        // Поведение пробела и курсора
        state.keyboardSettings.spacebarLongPressBehavior = .moveInputCursor
        state.keyboardSettings.spacebarMenuTrailing = nil
    }
}