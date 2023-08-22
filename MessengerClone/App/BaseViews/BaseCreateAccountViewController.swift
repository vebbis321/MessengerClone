//
//  DefaultCreateAccountVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//

import UIKit

class BaseCreateAccountViewController: UIViewController {
    weak var coordinator: CreateAccountCoordinator?

    // MARK: - Internal Components
    lazy var contentView = UIView(withAutolayout: true)

    // MARK: - Private Components
    private lazy var scrollView = UIScrollView(withAutolayout: true)
    private lazy var scrollContainerView = UIView(withAutolayout: true)

    private let titleLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        label.textColor = .theme.tintColor
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private lazy var alreadyHaveAnAccountBtn: UIButton = {
        let btn = UIButton(withAutolayout: true)
        btn.setTitle("Already have an account?", for: .normal)
        btn.setTitleColor(.theme.hyperlink, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0.01, right: 0) // 'hack' for removing padding
        btn.addTarget(self, action: #selector(alreadyHaveAnAccountTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - LifeCycle
    init(titleStr: String) {
        self.titleLabel.text = titleStr
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - setup
    private func setup() {
        // hide "back" from back button
        navigationController?.navigationBar.topItem?.backBarButtonItem = .init(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .theme.background

        view.addSubview(scrollView)
        view.addSubview(alreadyHaveAnAccountBtn)
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.addSubview(titleLabel)
        scrollContainerView.addSubview(contentView)

        // btn
        alreadyHaveAnAccountBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alreadyHaveAnAccountBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true

        // scrollView
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: alreadyHaveAnAccountBtn.topAnchor, constant: -10).isActive = true

        scrollContainerView.pin(to: scrollView)
        scrollContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // title
        titleLabel.topAnchor.constraint(equalTo: scrollContainerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: scrollContainerView.widthAnchor, constant: -40).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor).isActive = true

        // contentView
        contentView.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollContainerView.widthAnchor, constant: -40).isActive = true
        contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor).isActive = true
    }

    // MARK: - Private Actions
    @objc private func alreadyHaveAnAccountTapped() {
        let alert = AlertController(
            alertTitle: "Already have an acoount?",
            alertButtons: [
                .init(font: .systemFont(ofSize: 17, weight: .bold), title: "Log in", action: { [weak self] in
                    self?.dismiss(animated: true, completion: { [weak self] in
                        self?.coordinator?.rootViewController.popToRootViewController(animated: true)
                    })

                }),
                .init(font: .systemFont(ofSize: 17, weight: .regular), title: "Continue creating account", action: { [weak self] in
                    self?.dismiss(animated: true)
                }),
            ]
        )
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true, completion: nil)
    }
}
