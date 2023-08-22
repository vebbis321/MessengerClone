//
//  CollectionViewProfileImageCell.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/10/23.
//

import UIKit

final class CollectionViewProfileImageCell: UICollectionViewCell {
    private lazy var imageView = MessengerSDWebImage(size: 60)
    private lazy var nameLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        label.textColor = .label
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.setLineHeight(lineHeight: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(imageView)
        addSubview(nameLabel)

        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 7).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
    }

    func configure(with user: UserPublic) {
        imageView.configure(with: user.profileImageUrlString)
        let name = user.name.replacingOccurrences(of: " ", with: "\n")
        nameLabel.text = name
    }
}
