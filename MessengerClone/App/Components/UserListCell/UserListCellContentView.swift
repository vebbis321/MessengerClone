//
//  UserListCellContentView.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/10/23.
//

import UIKit

final class UserListCellContentView: UIView, UIContentView {
    private let imageHeight: CGFloat = 50

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, spacer])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 15
        stack.layoutMargins = .init(top: 10, left: 20, bottom: 10, right: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var imageView: MessengerSDWebImage = .init(size: imageHeight)

    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()

    private let spacer: UIView = .createSpacer()

    // MARK: - Properties
    private var currentConfiguration: UserListCellConfiguration!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        } set {
            guard let newConfiguration = newValue as? UserListCellConfiguration else {
                return
            }

            apply(configuration: newConfiguration)
        }
    }

    // MARK: - LifeCycle
    init(configuration: UserListCellConfiguration) {
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
    private func apply(configuration: UserListCellConfiguration) {
        guard currentConfiguration != configuration else {
            return
        }

        currentConfiguration = configuration

        guard let item = currentConfiguration.viewModel else { return }
        nameLabel.text = item.name
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        imageView.configure(with: item.profileImageUrlString)
    }

    // MARK: - setup
    private func setup() {
        addSubview(hStack)
        hStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hStack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hStack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        let bottomConstraint = hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        hStack.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
}
