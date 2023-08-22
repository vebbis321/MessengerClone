//
//  AddEmailVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import UIKit

final class AddEmailViewController: BaseCreateAccountViewController {
    // MARK: - Private components
    private lazy var subLabel: UILabel = .createSubLabel(
        text: "Enter the address at which you can be contacted. No one will see this on your profile.",
        withAutoLayout: true
    )
    private lazy var emailTextField = AuthTextField(
        viewModel: .init(
            type: .email,
            placeholderOption: .custom("Email address"),
            returnKey: .done
        )
    )
    private lazy var nextButton = AuthButton(viewModel: .init(title: "Next"))

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setup()
    }

    // MARK: - Private action
    private func buttonAction() {
        guard let validEmail = emailTextField.isValidText() else { return }

        view.endEditing(true)
        coordinator?.user.email = validEmail
        coordinator?.goToAddPasswordVC()
    }

    // MARK: - setup
    private func setup() {
        emailTextField.delegate = self
        nextButton.addAction(for: .touchUpInside) { [weak self] _ in
            self?.buttonAction()
        }
        contentView.addSubview(subLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(nextButton)

        subLabel.anchor(
            top: contentView.topAnchor,
            width: contentView.widthAnchor
        )

        emailTextField.anchor(
            top: subLabel.bottomAnchor, paddingTop: 30,
            width: contentView.widthAnchor
        )

        nextButton.anchor(
            top: emailTextField.bottomAnchor, paddingTop: 15,
            bottom: contentView.bottomAnchor,
            width: contentView.widthAnchor
        )
    }
}

extension AddEmailViewController: AuthTextFieldDelegate {
    func textFieldShouldReturn(_: AuthTextField) -> Bool {
        buttonAction()
        return true
    }
}
