//
//  MessengerSDWebImage.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/9/23.
//

import SDWebImage
import UIKit

final class MessengerSDWebImage: UIImageView {
    private var size: CGFloat

    // MARK: - LifeCycle
    init(frame: CGRect = .zero, size: CGFloat) {
        self.size = size
        super.init(frame: frame)

        setup()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit MessengerSDWebImage")
    }

    // MARK: - setup
    private func setup() {
        sd_imageTransition = .fade

        layer.cornerRadius = size / 2
        clipsToBounds = true

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: size).isActive = true
        widthAnchor.constraint(equalToConstant: size).isActive = true
    }

    // MARK: - configure
    func configure(with urlString: String?) {
        let transformer: SDImageRoundCornerTransformer = .init(
            radius: .greatestFiniteMagnitude,
            corners: .allCorners,
            borderWidth: 0,
            borderColor: nil
        )

        sd_setImage(
            with: .init(string: urlString ?? ""),
            placeholderImage: .init(named: "placeholderImage"),
            context: [.imageTransformer: transformer],
            progress: nil
        ) { _, _, _, _ in }
    }
}
