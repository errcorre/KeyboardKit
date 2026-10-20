import Foundation
import KeyboardKit
import UIKit

extension KeyboardLayout {

    static func demoLayout(
        for context: KeyboardContext
    ) -> KeyboardLayout {
        var layout = KeyboardLayout.standard(for: context)

        let inputWidth = KeyboardLayoutItem.Width.input

        // 1. Русская раскладка — подменяем буквы, ширину клавиш не трогаем
        //    отдельно от остальных (используем ту же .input-ширину, что и
        //    у английских букв в этом же ряду, так пропорции не ломаются).
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
                row3Items.append(shift) // keep Apple's own Shift width/geometry
            }
            for char in row3 {
                var item = layout.createIdealItem(for: .character(char))
                item.size.width = inputWidth
                row3Items.append(item)
            }
            if let backspace = layout.itemRows[2].last {
                row3Items.append(backspace) // keep Apple's own Backspace width/geometry
            }
            layout.itemRows[2] = row3Items
        }

        // 2. Вставка глобуса слева от пробела, справа от "123"
        if let bottomRowIndex = layout.itemRows.indices.last {
            var bottomRow = layout.itemRows[bottomRowIndex]

            bottomRow.removeAll {
                if case .custom(let name) = $0.action, name == "change_lang" { return true }
                return $0.action == .nextKeyboard || $0.action == .nextLocale
            }

            if let spaceIndex = bottomRow.firstIndex(where: { $0.action == .space }) {
                var globeItem = layout.createIdealItem(for: .custom(named: "change_lang"))
                globeItem.size.width = inputWidth
                bottomRow.insert(globeItem, at: spaceIndex)
            }

            layout.itemRows[bottomRowIndex] = bottomRow
        }

        // Никакой ручной геометрии (высота/инсеты) — используем то, что уже
        // честно посчитала .standard(for: context) для текущего устройства.
        return layout
    }
}