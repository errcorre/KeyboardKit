import Foundation
import KeyboardKit

extension KeyboardLayout {

    static func demoLayout(
        for context: KeyboardContext
    ) -> KeyboardLayout {
        var layout = KeyboardLayout.standard(for: context)

        // 1. Русская раскладка (если активен русский язык и алфавитный режим)
        if context.locale.identifier.hasPrefix("ru") && context.keyboardType.isAlphabetic {
            let isUpper = (context.keyboardCase == .uppercased || context.keyboardCase == .capsLocked)

            let row1 = isUpper
                ? ["Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х"]
                : ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"]

            let row2 = isUpper
                ? ["Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э"]
                : ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"]

            let row3 = isUpper
                ? ["Я", "Ч", "С", "М", "И", "Т", "Ь", "Б", "Ю"]
                : ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю"]

            let inputWidth = KeyboardLayoutItem.Width.input

            let row1Items: [KeyboardLayoutItem] = row1.map { char in
                var item = layout.createIdealItem(for: .character(char))
                item.size.width = inputWidth
                return item
            }

            let row2Items: [KeyboardLayoutItem] = row2.map { char in
                var item = layout.createIdealItem(for: .character(char))
                item.size.width = inputWidth
                return item
            }

            var row3Items: [KeyboardLayoutItem] = []
            if let shift = layout.itemRows[2].first {
                var s = shift
                s.size.width = inputWidth
                row3Items.append(s)
            }
            for char in row3 {
                var item = layout.createIdealItem(for: .character(char))
                item.size.width = inputWidth
                row3Items.append(item)
            }
            if let backspace = layout.itemRows[2].last {
                var b = backspace
                b.size.width = inputWidth
                row3Items.append(b)
            }

            layout.itemRows[0] = row1Items
            layout.itemRows[1] = row2Items
            layout.itemRows[2] = row3Items
        }

        // 2. Вставляем кнопку Глобуса в нижний ряд справа от "123" (или "ABC")
        if let bottomRowIndex = layout.itemRows.indices.last {
            var bottomRow = layout.itemRows[bottomRowIndex]

            // Убираем старую кнопку глобуса, если она где-то уже стояла
            bottomRow.removeAll { $0.action == .nextKeyboard || $0.action == .nextLocale }

            // Ищем кнопку 123 (или ABC в режиме цифр)
            if let keyboardTypeIndex = bottomRow.firstIndex(where: {
                if case .keyboardType = $0.action { return true }
                return false
            }) {
                var globeItem = layout.createIdealItem(for: .nextLocale)
                globeItem.size.width = KeyboardLayoutItem.Width.input
                // Вставляем сразу справа от 123
                bottomRow.insert(globeItem, at: keyboardTypeIndex + 1)
            }

            layout.itemRows[bottomRowIndex] = bottomRow
        }

        return layout
    }
}