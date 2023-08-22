//
//  AddPassvordVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import UIKit

final class AddPasswordViewController: BaseCreateAccountViewController {
    private lazy var subLabel: UILabel = .createSubLabel(
        text: "Create a password with at least 6 letters and numbers. It should be something that others can't guess.",
        withAutoLayout: true
    )
    private lazy var passwordTextField = AuthTextField(viewModel: .init(type: .password, returnKey: .done))
    private lazy var nextButton = AuthButton(viewModel: .init(title: "Next"))

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setup()
    }

    deinit {
        // so we don't keep in the coordinator
        coordinator?.password = nil
        print("✅ Deinit AddPasswordVC")
    }

    // MARK: - Private Action
    private func buttonAction() {
        guard let validPassword = passwordTextField.isValidText() else { return }
        view.endEditing(true)
        coordinator?.password = validPassword
        coordinator?.goToAgreeAndCreateAccountVC()
    }

    // MARK: - setup
    private func setup() {
        passwordTextField.delegate = self

        nextButton.addAction(for: .touchUpInside) { [weak self] _ in
            self?.buttonAction()
        }

        contentView.addSubview(subLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(nextButton)

        subLabel.anchor(
            top: contentView.topAnchor,
            width: contentView.widthAnchor
        )

        passwordTextField.anchor(
            top: subLabel.bottomAnchor, paddingTop: 30,
            width: contentView.widthAnchor
        )

        nextButton.anchor(
            top: passwordTextField.bottomAnchor, paddingTop: 15,
            bottom: contentView.bottomAnchor,
            width: contentView.widthAnchor
        )
    }
}

// MARK: - TextFieldDelegate
extension AddPasswordViewController: AuthTextFieldDelegate {
    func textFieldShouldReturn(_ textFieldView: AuthTextField) -> Bool {
        if textFieldView == passwordTextField {
            buttonAction()
        }
        return true
    }
}
