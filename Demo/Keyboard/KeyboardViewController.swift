//
//  KeyboardViewController.swift
//  KeyboardPro
//
//  Created by Daniel Saidi on 2023-02-13.
//  Copyright © 2023-2026 Kankoda. All rights reserved.
//

import KeyboardKit
import KeyboardKitHostPlugin                                // <-- 💡 Host Application
import SwiftUI

/// This keyboard shows how to set up `KeyboardKit Pro`, and
/// how to customize the keyboard in various ways.
///
/// This keyboard lets you test most features, like the many
/// languages, iPad-specific features, the autocomplete tool,
/// an emoji keyboard, themes, etc.
///
/// For app-specific features, check out the main app target.
class KeyboardViewController: KeyboardInputViewController {

    /// ‼️ If this doesn't log when the debugger is attached,
    /// there is a memory leak.
    deinit {
        NSLog("__DEINIT__")
    }

    /// This function is called when the controller launches,
    /// and is where you can set up KeyboardKit for your app.
    override func viewWillSetupKeyboardKit() {
        // Настраиваем стейт и сервисы сразу, без ожидания Pro лицензии
        setupDemoServices()
        setupDemoState()

        setupKeyboardKit(
            for: .keyboardKitDemo,
            hostApplicationResolver: pluginHostApplicationResolver
        ) { _ in }
    }   

    /// This function is called when the controller needs to
    /// redraw the keyboard view, and is where you can setup
    /// a custom view or customize the standard KeyboardView.
    override func viewWillSetupKeyboardView() {
        // super.viewWillSetupKeyboardView()                // <-- 💡 Don't call super.
        setupKeyboardView { /*[weak self]*/ controller in   // <-- 💡 Use weak or unowned self.
            DemoKeyboardView(                               // <-- 💡 Sets up a demo-specific keyboard view.
                services: controller.services,
                state: controller.state
            )
        }
    }
}

private extension KeyboardViewController {

    /// Make demo-specific changes to your keyboard services.
    func setupDemoServices() {
        DemoKeyboardActionHandler.inputController = self    // <-- нужно для textDocumentProxy
        services.actionHandler = DemoKeyboardActionHandler( // <-- 💡 Set up a demo-specific action handler.
            controller: self
        )
    }

    /// Make demo-specific changes to your keyboard's state.
    func setupDemoState() {
        state.keyboardContext.locales = [
            Locale(identifier: "en"),
            Locale(identifier: "ru")
        ]
        // Подключаем наш кастомный раскладчик
        services.layoutService = DemoLayoutService()
        
        /// 💡 Set up which locale to use to present locales.
        state.keyboardContext.locale = Locale(identifier: "en")
        state.keyboardContext.localePresentationLocale = .current

        // Регистр по умолчанию — строчные (маленькие буквы)
        state.keyboardContext.keyboardCase = .lowercased

        // 2. Поведение пробела и курсора
        state.keyboardSettings.spacebarLongPressBehavior = .moveInputCursor
        state.keyboardSettings.spacebarMenuTrailing = nil // убираем лишние иконки с пробела

        // 3. Автокомплит
        state.autocompleteSettings.isAutocorrectEnabled = true
    }
}
