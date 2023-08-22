//
//  ChatTextCellContentView.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import UIKit
import SDWebImage

final class ChatTextCellContentView: UIView, UIContentView {
    // MARK: - Components
    private lazy var containerHStack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .horizontal
        stack.spacing = 12
        stack.layoutMargins.left = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.alignment = .bottom
        return stack
    }()

    private lazy var recipientProfileImageView = MessengerSDWebImage(size: 30)

    private lazy var messageLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        label.numberOfLines = 0
        return label
    }()

    private lazy var bubbleBackgroundView: UIView = {
        let view = UIView(withAutolayout: true)
        view.layer.cornerRadius = 15
        return view
    }()

    // MARK: - Properties
    var leftConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!

    private var currentConfiguration: ChatMessageCellConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        } set {
            guard let newConfiguration = newValue as? ChatMessageCellConfiguration else {
                return
            }

            apply(configuration: newConfiguration)
        }
    }

    // MARK: - LifeCycle
    init(configuration: ChatMessageCellConfiguration) {
        super.init(frame: .zero)

        // create the content view UI
        setup()

        // apply the configuration (set data to UI elements / define custom content view appearance)
        apply(configuration: configuration)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    private func apply(configuration: ChatMessageCellConfiguration) {
        guard currentConfiguration != configuration, let viewModel = configuration.viewModel else {
            return
        }
        currentConfiguration = configuration

        leftConstraint.isActive = !viewModel.item.sentByCurrentUser
        rightConstraint.isActive = viewModel.item.sentByCurrentUser

        messageLabel.textColor = viewModel.messageLabelTextColor
        bubbleBackgroundView.backgroundColor = viewModel.textBackgroundColor
        messageLabel.text = viewModel.item.message

        if viewModel.isLastMessage, !viewModel.item.sentByCurrentUser {
            Task {
                let recipient = try? await LocalDatabase.shared.readForId(uuid: viewModel.item.fromId)
                recipientProfileImageView.configure(with: recipient?.profileImageUrl)
            }
        } else {
            recipientProfileImageView.image = nil
        }

        if !viewModel.isPreviousMessageSentByCurrent {
            topConstraint.constant = 4

        } else {
            topConstraint.constant = 0
        }
    }

    // MARK: - setup
    private func setup() {

        bubbleBackgroundView.addSubview(messageLabel)
        
        containerHStack.addArrangedSubview(recipientProfileImageView)
        containerHStack.addArrangedSubview(bubbleBackgroundView)

        addSubview(containerHStack)

        topConstraint = containerHStack.topAnchor.constraint(equalTo: topAnchor)
        topConstraint.isActive = true

        containerHStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        bubbleBackgroundView.anchor(
            top: messageLabel.topAnchor, paddingTop: -10,
            bottom: messageLabel.bottomAnchor, paddingBottom: -10,
            left: messageLabel.leftAnchor, paddingLeft: -10,
            right: messageLabel.rightAnchor, paddingRight: -10
        )

        leftConstraint = containerHStack.leftAnchor.constraint(equalTo: leftAnchor)
        rightConstraint = containerHStack.rightAnchor.constraint(equalTo: rightAnchor)

        let containerWidth = messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: getWindowWidth() * 0.7)
        //        containerWidth.priority = .defaultLow
        containerWidth.isActive = true
    }
}
