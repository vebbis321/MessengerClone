//
//  UIStackView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//

import UIKit

// MARK: - customize
extension UIStackView {
    func customize(backgroundColor: UIColor = .clear, cornerRadius: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)

        subView.layer.cornerRadius = cornerRadius
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
    }
}

// MARK: - seperator
extension UIStackView {
    func addHorizontalSeparators(color: UIColor) {
        var i = arrangedSubviews.count - 1
        while i > 0 {
            let separator = createSeparator(color: color)
            insertArrangedSubview(separator, at: i)
            separator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
            i -= 1
        }
    }

    private func createSeparator(color: UIColor) -> UIView {
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.backgroundColor = color
        return separator
    }
}
