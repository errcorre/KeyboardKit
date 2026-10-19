import Foundation
import KeyboardKit

extension KeyboardLayout {

    static func demoLayout(
        for context: KeyboardContext
    ) -> KeyboardLayout {
        var layout = KeyboardLayout.standard(for: context)

        // Применяем русскую раскладку только для буквенного режима
        guard context.locale.identifier.hasPrefix("ru"),
              context.keyboardType.isAlphabetic else {
            return layout
        }

        // Проверяем состояние Shift / CapsLock
        let isUpper = (context.keyboardCase == .uppercased || context.keyboardCase == .capsLocked)

        // 1-й ряд (11 клавиш)
        let row1 = isUpper
            ? ["Й", "Ц", "У", "К", "Е", "Н", "Г", "Ш", "Щ", "З", "Х"]
            : ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х"]

        // 2-й ряд (11 клавиш)
        let row2 = isUpper
            ? ["Ф", "Ы", "В", "А", "П", "Р", "О", "Л", "Д", "Ж", "Э"]
            : ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"]

        // 3-й ряд (9 клавиш между Shift и Backspace)
        let row3 = isUpper
            ? ["Я", "Ч", "С", "М", "И", "Т", "Ь", "Б", "Ю"]
            : ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю"]

        let inputWidth = KeyboardLayoutItem.Width.input

        // Собираем первый ряд
        let row1Items: [KeyboardLayoutItem] = row1.map { char in
            var item = layout.createIdealItem(for: .character(char))
            item.size.width = inputWidth
            return item
        }

        // Собираем второй ряд
        let row2Items: [KeyboardLayoutItem] = row2.map { char in
            var item = layout.createIdealItem(for: .character(char))
            item.size.width = inputWidth
            return item
        }

        // Собираем третий ряд (Shift + 9 букв + Backspace)
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

        return layout
    }
}