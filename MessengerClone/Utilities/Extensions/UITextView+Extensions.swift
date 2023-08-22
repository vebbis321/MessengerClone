//
//  UITextView+Extensions.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/11/23.
//

import Combine
import UIKit

// MARK: - 2-way binding
extension UITextView {
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
extension UITextView {
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextView)?.text }
            .eraseToAnyPublisher()
    }
}

// MARK: - ScrollToBottom
extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
    }
}
