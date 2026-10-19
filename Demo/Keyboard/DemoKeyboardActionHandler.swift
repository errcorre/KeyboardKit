//
//  DemoKeyboardActionHandler.swift
//  KeyboardPro
//
//  Created by Daniel Saidi on 2021-02-11.
//  Copyright © 2021-2026 Kankoda. All rights reserved.
//

import KeyboardKit
import UIKit

/// This action handler inherits the standard action handler
/// and makes demo-specific adjustments to it.
class DemoKeyboardActionHandler: StandardKeyboardActionHandler {

    /// Trigger custom actions for `.image` keyboard actions.
    override func action(
        for gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        let standard = super.action(for: gesture, on: action)
        switch gesture {
        case .longPress: return longPressAction(for: action) ?? standard
        case .release: return releaseAction(for: action) ?? standard
        default: return standard
        }
    }
    
    /// Save an image to Photos when you long press it.
    func longPressAction(
        for action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        switch action {
        case .image(_, _, let imageName): { [weak self] _ in self?.saveImage(named: imageName) }
        default: nil
        }
    }

    /// Copy an image to the pasteboard when you tap it.
    func releaseAction(
        for action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        switch action {
        case .image(_, _, let imageName): { [weak self] _ in self?.copyImage(named: imageName) }
        default: nil
        }
    }

    // MARK: - Swipe-to-delete on backspace

    /// How many points of leftward drag trigger the next deletion step.
    private static let wordDeleteStepWidth: CGFloat = 25

    /// Past this cumulative drag distance, each further step deletes a
    /// whole sentence instead of a single word.
    private static let sentenceModeThreshold: CGFloat = 180

    /// How many deletion "steps" we've already performed for the drag
    /// gesture currently in progress. Reset whenever a new drag begins.
    private var backspaceDragStepsTriggered = 0
    private var backspaceDragStart: CGPoint?

    override func handleDrag(
        on action: KeyboardAction,
        from startLocation: CGPoint,
        to currentLocation: CGPoint
    ) {
        guard action == .backspace else {
            return super.handleDrag(on: action, from: startLocation, to: currentLocation)
        }

        // Detect a fresh drag gesture (a new press+drag) vs. continuation
        // of the one in progress, so we don't reset step counting mid-swipe.
        if backspaceDragStart != startLocation {
            backspaceDragStart = startLocation
            backspaceDragStepsTriggered = 0
        }

        let distance = startLocation.x - currentLocation.x // swiping LEFT is positive
        guard distance > 0 else { return }

        let wordSteps = Int(Self.sentenceModeThreshold / Self.wordDeleteStepWidth)
        let stepsForDistance: Int
        if distance < Self.sentenceModeThreshold {
            stepsForDistance = Int(distance / Self.wordDeleteStepWidth)
        } else {
            let extraDistance = distance - Self.sentenceModeThreshold
            let extraSteps = Int(extraDistance / (Self.wordDeleteStepWidth * 3))
            stepsForDistance = wordSteps + extraSteps
        }

        guard stepsForDistance > backspaceDragStepsTriggered else { return }
        let newSteps = stepsForDistance - backspaceDragStepsTriggered
        backspaceDragStepsTriggered = stepsForDistance

        for _ in 0..<newSteps {
            if distance >= Self.sentenceModeThreshold {
                deleteCurrentSentence()
            } else {
                deleteCurrentWord()
            }
        }
    }
}

private extension DemoKeyboardActionHandler {

    func alert(_ message: String) {
        print("Implement alert functionality if you want.")
    }

    func copyImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to copy images.") }
        guard image.copyToPasteboard() else { return alert("The image could not be copied.") }
        alert("Copied to pasteboard!")
    }
    func handleImageDidSave(withError error: Error?) {
        if error == nil { alert("Saved!") }
        else { alert("Failed!") }
    }

    func saveImage(named imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        guard keyboardContext.hasFullAccess else { return alert("You must enable full access to save images.") }
        image.saveToPhotos(completion: handleImageDidSave)
        alert("Saved to photos!")
    }

     /// Deletes the word immediately before the cursor, including any
    /// trailing whitespace right before it.
    func deleteCurrentWord() {
        let proxy = keyboardContext.textDocumentProxy
        guard var text = proxy.documentContextBeforeInput, !text.isEmpty else {
            return proxy.deleteBackward()
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

        guard deletions > 0 else { return proxy.deleteBackward() }
        for _ in 0..<deletions { proxy.deleteBackward() }
    }

    /// Deletes back to the start of the current sentence (the last
    /// `.`, `!`, `?` or newline before the cursor), or to the start
    /// of the text if there is no earlier sentence boundary.
    func deleteCurrentSentence() {
        let proxy = keyboardContext.textDocumentProxy
        guard var text = proxy.documentContextBeforeInput, !text.isEmpty else {
            return proxy.deleteBackward()
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

        guard deletions > 0 else { return proxy.deleteBackward() }
        for _ in 0..<deletions { proxy.deleteBackward() }
    }
}

private extension UIImage {
    
    func copyToPasteboard(_ pasteboard: UIPasteboard = .general) -> Bool {
        guard let data = pngData() else { return false }
        pasteboard.setData(data, forPasteboardType: "public.png")
        return true
    }
}

private extension UIImage {
    
    func saveToPhotos(completion: @escaping (Error?) -> Void) {
        ImageService.default.saveImageToPhotos(self, completion: completion)
    }
}


/// This class is used as target by the extension above.
private class ImageService: NSObject {
    
    public typealias Completion = (Error?) -> Void

    public static private(set) var `default` = ImageService()
    
    private var completions = [Completion]()
    
    public func saveImageToPhotos(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageToPhotosDidComplete), nil)
    }
    
    @objc func saveImageToPhotosDidComplete(_ image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        guard completions.count > 0 else { return }
        completions.removeFirst()(error)
    }
}
