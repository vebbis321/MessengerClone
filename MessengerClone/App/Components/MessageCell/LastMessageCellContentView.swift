//
//  ChatRoomContentView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/25/23.
//

import UIKit

class LastMessageCellContentView: UIView, UIContentView {
    // MARK: - Private components
    private lazy var textVStack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 1
        return stack
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 15
        stack.layoutMargins = .init(top: 10, left: 20, bottom: 10, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    private lazy var imageView: MessengerSDWebImage = .init(size: 60)

    private lazy var nameLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        return label
    }()

    private lazy var lastMessagelabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        return label
    }()

    private let spacer: UIView = .createSpacer()

    // MARK: - Properties
    private var currentConfiguration: LastMessageCellConfiguration!

    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        } set {
            guard let newConfiguration = newValue as? LastMessageCellConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }

    // MARK: - LifeCycle
    init(configuration: LastMessageCellConfiguration) {
        super.init(frame: .zero)

        // create the content view UI
        setup()

        // apply the configuration (set data to UI elements / define custom content view appearance)
        apply(configuration: configuration)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - apply
    private func apply(configuration: LastMessageCellConfiguration) {
        guard currentConfiguration != configuration,
            let viewModel = configuration.viewModel else {
            return
        }

        Task {
            let cachedUser = try await viewModel.getCachedUser()
            nameLabel.text = cachedUser?.name
            imageView.configure(with: cachedUser?.profileImageUrl)
        }

        currentConfiguration = configuration
        lastMessagelabel.text = viewModel.item.lastMessage
        nameLabel.font = viewModel.chatNameFont
        lastMessagelabel.font = viewModel.messageLabelFont
    }

    // MARK: - setup
    private func setup() {
        textVStack.addArrangedSubview(nameLabel)
        textVStack.addArrangedSubview(lastMessagelabel)

        hStack.addArrangedSubview(imageView)
        hStack.addArrangedSubview(textVStack)
        hStack.addArrangedSubview(spacer)

        addSubview(hStack)

        nameLabel.anchor(
            left: textVStack.leftAnchor
        )

        lastMessagelabel.anchor(
            left: textVStack.leftAnchor
        )

        imageView.anchor(
            widthConstant: 60
        )

        hStack.anchor(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor
        )

        let bottomConstraint = hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        hStack.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
}
