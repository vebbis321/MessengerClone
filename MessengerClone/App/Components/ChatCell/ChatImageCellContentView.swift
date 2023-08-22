//
//  ChatImageCellContentView.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import UIKit

final class ChatImageCellContentView: UIView, UIContentView {
    // MARK: - Components
    private lazy var imageView = UIImageView(withAutolayout: true)

    // MARK: - Properties
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
        guard currentConfiguration != configuration else {
            return
        }

        currentConfiguration = configuration

        guard let item = currentConfiguration.viewModel else { return }
        //        imageView.setUpLoadImageView(urlString: item.profileImageUrlString)
        //        nameLabel.text = item.name
        //        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    }

    // MARK: - setup
    private func setup() {
        backgroundColor = .red
    }
}
