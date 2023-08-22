//
//  CollectionViewLoadingCell.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/7/23.
//

import UIKit

final class CollectionViewLoadingCell: UICollectionViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        return indicator
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(activityIndicator)
        constrain()
    }

    private func constrain() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func startAnimation() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
