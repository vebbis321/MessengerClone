//
//  UILabel+Extensions.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/10/23.
//

import UIKit

// MARK: - SetLineHeight
extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        guard let text = self.text else { return }

        let attributeString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()

        style.lineSpacing = lineHeight
        attributeString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: style,
            range: NSRange(location: 0, length: attributeString.length)
        )

        self.attributedText = attributeString
    }
}
