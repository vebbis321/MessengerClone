//
//  NameTagCell.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import UIKit

final class NameTagCell: UICollectionViewCell {
    var text: String? {
        didSet {
            tagLabel.text = text
        }
    }

    var action: (() -> Void)?

    private lazy var tagLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var closeBtn: UIButton = {
        let btn = IncreaseTapAreaButton()
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let iconImage = UIImage(systemName: "xmark.circle", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        btn.setImage(iconImage, for: .normal)
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addAction(for: .touchUpInside) { [weak self] _ in
            self?.action?()
        }
        return btn
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tagLabel, closeBtn])
        stack.spacing = 3
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.layoutMargins = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        text = nil
        action = nil
    }

    // MARK: - setup
    private func setup() {
        layer.masksToBounds = false
        layer.backgroundColor = UIColor.clear.cgColor

        contentView.layer.masksToBounds = true
        layer.cornerRadius = 6
        backgroundColor = .blue

        contentView.addSubview(hStack)

        hStack.pin(to: contentView)
    }
}
