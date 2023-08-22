//
//  NavBarProfileView.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/16/23.
//

import UIKit

final class NavBarProfileView: UIStackView {
    // MARK: - Private Components
    private var imageView: MessengerSDWebImage
    private lazy var label: UILabel = .createLabel(
        font: .preferredFont(forTextStyle: .headline),
        alignment: .left,
        withAutoLayout: true
    )
    private let spacer: UIView = .createSpacer()

    // MARK: - Private properties
    private let viewModel: ViewModel

    // MARK: - LifeCycle
    init(
        viewModel: ViewModel,
        imgSize: CGFloat = 30
    ) {
        self.viewModel = viewModel
        self.imageView = .init(size: imgSize)
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable) required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        label.text = viewModel.text
        imageView.configure(with: viewModel.profileImaggeUrlString)

        axis = .horizontal
        distribution = .fill
        spacing = 5
        alignment = .center
        isUserInteractionEnabled = true

        addArrangedSubview(imageView)
        addArrangedSubview(label)
        addArrangedSubview(spacer)
    }
}

extension NavBarProfileView {
    struct ViewModel {
        var text: String
        var profileImaggeUrlString: String?

        init(chatTitle: String?, recipients: [UserPublic]) {
            if let chatTitle {
                self.text = chatTitle
                self.profileImaggeUrlString = recipients[0].profileImageUrlString
            } else if recipients.count > 1 {
                self.text = recipients[0].name
                self.profileImaggeUrlString = recipients[0].profileImageUrlString
            } else {
                self.text = recipients[0].name
                self.profileImaggeUrlString = recipients[0].profileImageUrlString
            }
        }
    }
}
