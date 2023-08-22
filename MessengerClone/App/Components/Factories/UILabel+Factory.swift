//
//  UILabel+Components.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/7/23.
//

import UIKit

extension UILabel {
    /// Default title label for a ViewController.
    /// - Parameter text: textStr
    /// - Returns: Self
    static func createTitleLabel(text: String, withAutoLayout: Bool) -> UILabel {
        let label = UILabel(withAutolayout: withAutoLayout)
        label.text = text
        label.textColor = .theme.tintColor
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        return label
    }

    /// Default sub-label for a ViewController.
    /// - Parameter text: textStr
    /// - Returns: Self
    static func createSubLabel(text: String, withAutoLayout: Bool) -> UILabel {
        let label = UILabel(withAutolayout: withAutoLayout)
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.text = text
        label.numberOfLines = 0

        return label
    }

    static func createLabel(
        text: String? = nil,
        color: UIColor = .label,
        font: UIFont,
        alignment: NSTextAlignment,
        numberOfLines: Int = 0,
        withAutoLayout: Bool
    )
        -> UILabel {
        let label = UILabel(withAutolayout: withAutoLayout)
        label.text = text
        label.textColor = color
        label.font = font
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        return label
    }

    //    override init(frame: CGRect = .zero) {
    //        super.init(frame: frame)
    //        setUpLayout()
    //    }
    //
    //    convenience init(customFont: UIFont, textColor: UIColor, textAlignment: NSTextAlignment) {
    //        self.init(frame: .zero)
    //        self.font = customFont
    //        self.textColor = textColor
    //        self.textAlignment = textAlignment
    //
    //    }
    //
    //    private func setUpLayout() {
    //        self.numberOfLines = 0
    //        translatesAutoresizingMaskIntoConstraints = false
    //    }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    // }
}
