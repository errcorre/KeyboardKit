import KeyboardKit
import UIKit

class DemoKeyboardActionHandler: StandardKeyboardActionHandler {

    static weak var inputController: UIInputViewController?

    private var textProxy: UITextDocumentProxy? {
        Self.inputController?.textDocumentProxy
    }

    // MARK: - Gesture Settings & Thresholds
    /// Свайп влево начинает удалять слова только после преодоления 160pt (середина пробела)
    private static let activationThreshold: CGFloat = 160

    /// Шаг удаления слов (чем выше число, тем плавнее удаление)
    private static let wordDeleteStepWidth: CGFloat = 45

    /// Дистанция до левой четверти экрана, где включается удаление предложений
    private static let sentenceDistanceThreshold: CGFloat = 280

    /// Шаг удаления предложений
    private static let sentenceDeleteStepWidth: CGFloat = 60

    // MARK: - Gesture State
    private var backspaceDragStart: CGPoint?
    private var backspaceDragStepsTriggered = 0
    private var isSentenceMode = false
    private var holdTimer: Timer?

    // MARK: - Overrides

    override func action(
        for gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        // Мгновенное переключение языка En <-> Ru по нажатию на наш глобус
        if gesture == .release {
            if case .custom(let name) = action, name == "change_lang" {
                return { [weak self] _ in
                    guard let context = self?.keyboardContext else { return }
                    context.selectNextLocale()
                }
            }
        }

        let standard = super.action(for: gesture, on: action)
        switch gesture {
        case .longPress: return longPressAction(for: action) ?? standard
        case .release: return releaseAction(for: action) ?? standard
        default: return standard
        }
    }

    func longPressAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        switch action {
        case .image(_, _, let imageName): return { [weak self] _ in self?.saveImage(named: imageName) }
        default: return nil
        }
    }

    func releaseAction(for action: KeyboardAction) -> KeyboardAction.GestureAction? {
        resetBackspaceDragState()
        switch action {
        case .image(_, _, let imageName): return { [weak self] _ in self?.copyImage(named: imageName) }
        default: return nil
        }
    }

    override func handleDrag(
        on action: KeyboardAction,
        from startLocation: CGPoint,
        to currentLocation: CGPoint
    ) {
        guard action == .backspace else {
            super.handleDrag(on: action, from: startLocation, to: currentLocation)
            return
        }

        if backspaceDragStart != startLocation {
            resetBackspaceDragState()
            backspaceDragStart = startLocation
        }

        let distance = startLocation.x - currentLocation.x // свайп влево

        // 1. Не удаляем ничего, пока свайп не дошёл до середины пробела
        guard distance >= Self.activationThreshold else {
            holdTimer?.invalidate()
            holdTimer = nil
            return
        }

        // 2. Таймер на 2 секунды удержания для переключения в режим предложений
        restartHoldTimer()

        // 3. Переход в режим предложений по расстоянию (1/4 клавиатуры)
        if distance >= Self.sentenceDistanceThreshold {
            isSentenceMode = true
        }

        let activeDistance = distance - Self.activationThreshold
        let stepWidth = isSentenceMode ? Self.sentenceDeleteStepWidth : Self.wordDeleteStepWidth
        let totalSteps = Int(activeDistance / stepWidth)

        guard totalSteps > backspaceDragStepsTriggered else { return }
        let newSteps = totalSteps - backspaceDragStepsTriggered
        backspaceDragStepsTriggered = totalSteps

        for _ in 0..<newSteps {
            if isSentenceMode {
                deleteCurrentSentence()
            } else {
                deleteCurrentWord()
            }
        }
    }

    private func resetBackspaceDragState() {
        backspaceDragStart = nil
        backspaceDragStepsTriggered = 0
        isSentenceMode = false
        holdTimer?.invalidate()
        holdTimer = nil
    }

    private func restartHoldTimer() {
        holdTimer?.invalidate()
        holdTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isSentenceMode = true
            self.deleteCurrentSentence()
        }
    }
}

// MARK: - Deletion Logic & Helpers
private extension DemoKeyboardActionHandler {

    func deleteCurrentWord() {
        guard let proxy = textProxy else { return }
        guard var text = proxy.documentContextBeforeInput, !text.isEmpty else {
            proxy.deleteBackward()
            return
        }

        var deletions = 0
        while let last = text.last, last.isWhitespace {
            text.removeLast()
            deletions += 1
        }
        while let last = text.last, !last.isWhitespace {
            text.removeLast()
            deletions += 1
        }

        guard deletions > 0 else {
            proxy.deleteBackward()
            return
        }
        for _ in 0..<deletions {
            proxy.deleteBackward()
        }
    }

    func deleteCurrentSentence() {
        guard let proxy = textProxy else { return }
        guard var text = proxy.documentContextBeforeInput, !text.isEmpty else {
            proxy.deleteBackward()
            return
        }

        let sentenceEnders: Set<Character> = [".", "!", "?", "\n"]
        var deletions = 0
        while let last = text.last, last.isWhitespace {
            text.removeLast()
            deletions += 1
        }
        while let last = text.last, !sentenceEnders.contains(last) {
            text.removeLast()
            deletions += 1
        }

        guard deletions > 0 else {
            proxy.deleteBackward()
            return
        }
        for _ in 0..<deletions {
            proxy.deleteBackward()
        }
    }

    func alert(_ message: String) {
        print(message)
    }

    func copyImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to copy images.") }
        guard image.copyToPasteboard() else { return alert("The image could not be copied.") }
        alert("Copied to pasteboard!")
    }

    func saveImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to save images.") }
        image.saveToPhotos { [weak self] error in
            if error == nil { self?.alert("Saved!") }
            else { self?.alert("Failed!") }
        }
    }
}

private extension UIImage {
    func copyToPasteboard(_ pasteboard: UIPasteboard = .general) -> Bool {
        guard let data = pngData() else { return false }
        pasteboard.setData(data, forPasteboardType: "public.png")
        return true
    }

    func saveToPhotos(completion: @escaping (Error?) -> Void) {
        ImageService.default.saveImageToPhotos(self, completion: completion)
    }
}

private class ImageService: NSObject {
    typealias Completion = (Error?) -> Void
    static let `default` = ImageService()
    private var completions = [Completion]()

    func saveImageToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageToPhotosDidComplete), nil)
    }

    @objc func saveImageToPhotosDidComplete(_ image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        guard !completions.isEmpty else { return }
        completions.removeFirst()(error)
    }
}