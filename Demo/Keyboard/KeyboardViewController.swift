import KeyboardKit
import KeyboardKitHostPlugin
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {

    deinit {
        NSLog("__DEINIT__")
    }

    override func viewWillSetupKeyboardKit() {
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

    override func setPreferredKeyboardCase() {
        // Намеренно пусто — отключает автоматическую смену регистра.
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
        state.keyboardContext.locales = [
            Locale(identifier: "en"),
            Locale(identifier: "ru")
        ]
        state.keyboardContext.locale = Locale(identifier: "en")
        state.keyboardContext.localePresentationLocale = .current

        state.keyboardSettings.spacebarLongPressBehavior = .moveInputCursor
        state.keyboardSettings.spacebarMenuTrailing = nil
    }
}