//
//  AuthButton.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/19/23.
//

import UIKit

final class AuthButton: UIButton {
    // MARK: - Private Components
    private lazy var spinner = SpinnerView(colors: [.white], lineWidth: 2)

    // MARK: - Private Properties
    private var viewModel: ViewModel

    // MARK: - Public Properties
    var isLoading = false {
        didSet {
            updateView()
        }
    }

    // MARK: - LifeCycle
    init(frame: CGRect = .zero, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit AuthButton")
    }

    // MARK: - Public Methods
    func updateView() {
        if isLoading {
            spinner.isAnimating = true
            titleLabel?.alpha = 0
            imageView?.alpha = 0
            // to prevent multiple click while in process
            isEnabled = false
        } else {
            spinner.isAnimating = false
            titleLabel?.alpha = 1
            imageView?.alpha = 0
            isEnabled = true
        }
    }

    // MARK: - setup
    private func setup() {
        // self
        backgroundColor = viewModel.backgroundColor
        setTitleColor(viewModel.textColor, for: .normal)
        setTitleColor(viewModel.textColor, for: .highlighted)
        layer.cornerRadius = 3
        layer.borderWidth = viewModel.borderWidth
        layer.borderColor = viewModel.borderColor?.cgColor
        layer.masksToBounds = true
        setTitle(viewModel.title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)

        // activityIndicator
        addSubview(spinner)

        guard let titleLabel else { return }

        // self
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -15).isActive = true
        bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true

        // activityIndicator
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.heightAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.height).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.height).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
