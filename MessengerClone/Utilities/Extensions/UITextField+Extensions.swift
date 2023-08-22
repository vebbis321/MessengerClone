//
//  UITextField.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/14/23.
//

import Combine
import UIKit

// MARK: - Edit placeHolder font
extension UITextField {
    func changePlaceholderText(placeholderText: String, font: UIFont, color: UIColor = .theme.placeholder ?? .gray) {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: font,
            ]
        )
    }
}

// MARK: - 2-way binding
extension UITextField {
    func createBinding(
        with subject: CurrentValueSubject<String, Never>,
        storeIn subscriptions: inout Set<AnyCancellable>
    ) {
        subject.sink { [weak self] value in
            if value != self?.text {
                self?.text = value
            }
        }.store(in: &subscriptions)

        self.textPublisher().sink { value in
            if value != subject.value {
                subject.send(value)
            }
        }.store(in: &subscriptions)
    }
}

// MARK: - Publishers
extension UITextField {
    func textBecameActivePublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidBeginEditingNotification, object: self)
            .map { ($0.object as? UITextField)?.isEditing ?? false }
            .eraseToAnyPublisher()
    }

    func textBecameInActivePublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidEndEditingNotification, object: self)
            .map { ($0.object as? UITextField)?.isEditing ?? false }
            .eraseToAnyPublisher()
    }

    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }

    func textIsEmptyPublisher() -> AnyPublisher<Bool, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text?.isEmpty ?? true }
            .eraseToAnyPublisher()
    }
}

// MARK: - togglePasswordVisibility
extension UITextField {
    func togglePasswordVisibility() {
        isSecureTextEntry.toggle()

        if let existingText = text, isSecureTextEntry {
            // When toggling to secure text, all text will be purged if the user
            // continues typing unless we intervene. This is prevented by first
            // deleting the existing text and then recovering the original text.
            deleteBackward()

            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }

        // Reset the selected text range since the cursor can end up in the wrong
        // position after a toggle because the text might vary in width
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }

        becomeFirstResponder()
    }
}
