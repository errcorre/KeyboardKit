import KeyboardKit
import KeyboardKitHostPlugin
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {

    deinit {
        NSLog("__DEINIT__")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Гарантируем, что при открытии клавиатуры или смене поля ввода
        // регистр всегда принудительно сбрасывается в строчный
        state.keyboardContext.keyboardCase = .lowercased
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
        
        // --- БЛОК ОТКЛЮЧЕНИЯ АВТОКАПИТАЛИЗАЦИИ ---
        // 1. Отключаем автокапитализацию KeyboardKit
        state.keyboardSettings.isAutocapitalizationEnabled = false
        // 2. Игнорируем системные требования iOS к регистру для текстовых полей
        state.keyboardContext.autocapitalizationTypeOverride = .none
        // 3. Устанавливаем дефолтный регистр как нижний
        state.keyboardContext.keyboardCase = .lowercased
        // ----------------------------------------

        // Поведение пробела и курсора
        state.keyboardSettings.spacebarLongPressBehavior = .moveInputCursor
        state.keyboardSettings.spacebarMenuTrailing = nil
    }
}