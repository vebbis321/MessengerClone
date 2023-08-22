//
//  CustomSheetVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/23/23.
//

import UIKit

final class BirthdaysInfoView: UIView {
    // MARK: - Private Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        label.text = "Birthdays"
        label.textColor = .theme.tintColor
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private lazy var linkTextView: TappableTextView = {
        let textView = TappableTextView(customBackgroundColor: .secondarySystemBackground)
        textView.translatesAutoresizingMaskIntoConstraints = false
        // linkTextView
        let linkText = """
            Learn \
            more about how we use your info in our Privacy Policy
            """
        textView
            .text =
            """
            Providing your date of birth improves the features and \
            ads that you see and helps to keep the Facebook \
            community safe. You can find your date of birth in \
            your personal infromation account settings. \(linkText)
            """
        textView.addTappableTexts([linkText: "https://www.facebook.com/privacy/policy/"])
        return textView
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setup
    private func setup() {
        // self
        backgroundColor = .secondarySystemBackground

        addSubview(titleLabel)
        addSubview(linkTextView)

        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        linkTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        linkTextView.pinSides(to: self)
    }
}
