//
//  CollectionViewEmptyChatCell.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/18/23.
//

import SDWebImage
import UIKit

final class CollectionViewEmptyChatCell: UICollectionViewCell {
    lazy var profileImage = MessengerSDWebImage(size: 100)
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        addSubview(profileImage)
        addSubview(nameLabel)

        profileImage.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        profileImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 15).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
    }

    func configure(model: UserPublic) {
        nameLabel.text = model.name
        profileImage.configure(with: model.profileImageUrlString)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
        nameLabel.text = nil
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class EmptyChatPlaceholderTableViewCell: UITableViewCell {
    lazy var profileImage = MessengerSDWebImage(size: 100)
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    private func setup() {
        addSubview(profileImage)
        addSubview(nameLabel)

        profileImage.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        profileImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 15).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true
    }

    func configure(model: UserPublic) {
        nameLabel.text = model.name
        profileImage.configure(with: model.profileImageUrlString)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
        nameLabel.text = nil
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
