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

            layout.itemRows[0] = row1.map { char in
                var item = layout.createIdealItem(for: .character(char))
                item.size.width = inputWidth
                return item
            }

            layout.itemRows[1] = row2.map { char in
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
            layout.itemRows[2] = row3Items
        }

        // 2. Вставка ГЛОБУСА в нижний ряд (кастомное действие, которое iOS не скроет)
        if let bottomRowIndex = layout.itemRows.indices.last {
            var bottomRow = layout.itemRows[bottomRowIndex]

            // Убираем старые глобусы/переключатели, если они где-то есть
            bottomRow.removeAll {
                if case .custom(let name) = $0.action, name == "change_lang" { return true }
                return $0.action == .nextKeyboard || $0.action == .nextLocale
            }

            // Находим позицию пробела и вставляем глобус прямо перед ним (справа от 123)
            if let spaceIndex = bottomRow.firstIndex(where: { $0.action == .space }) {
                var globeItem = layout.createIdealItem(for: .custom(named: "change_lang"))
                globeItem.size.width = KeyboardLayoutItem.Width.input
                bottomRow.insert(globeItem, at: spaceIndex)
            }

            layout.itemRows[bottomRowIndex] = bottomRow
        }

        return layout
    }
}