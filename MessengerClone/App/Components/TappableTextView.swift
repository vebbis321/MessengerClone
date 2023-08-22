//
//  SubLinkTextView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/22/23.
//

import UIKit

class TappableTextView: UITextView {
    // MARK: - Public Properties
    var onTextTap: OnTextTap?

    // MARK: - Definitions
    typealias URLString = String
    typealias ShowURL = Bool
    typealias TappableTexts = [String: URLString?]
    typealias OnTextTap = () -> ShowURL

    // MARK: - LifeCycle
    init(frame: CGRect = .zero, customBackgroundColor: UIColor? = .theme.background) {
        super.init(frame: frame, textContainer: nil)
        isEditable = false
        isSelectable = true
        isScrollEnabled = false // to have own size and behave like a label
        delegate = self
        font = .preferredFont(forTextStyle: .subheadline)
        backgroundColor = customBackgroundColor
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0.0
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Public Methods
    func addTappableTexts(_ tappableTexts: TappableTexts) {
        guard attributedText.length > 0 else {
            return
        }
        let mText = NSMutableAttributedString(attributedString: attributedText)

        for (text, optionalUrl) in tappableTexts where !text.isEmpty {
            let linkRange = mText.mutableString.range(of: text)
            mText.addAttribute(.link, value: optionalUrl ?? "", range: linkRange)
        }
        attributedText = mText
    }
}

// MARK: - UITextViewDelegate
extension TappableTextView: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith _: URL, in _: NSRange) -> Bool {
        return onTextTap?() ?? true
    }

    // to disable text selection
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
