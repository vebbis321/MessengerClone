//
//  AddNameVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//

import Combine
import UIKit

final class AddNameViewController: BaseCreateAccountViewController {
    // MARK: - Private components
    private lazy var subLabel: UILabel = .createSubLabel(
        text: "Enter the name you use in real life.",
        withAutoLayout: true
    )
    private lazy var hStack = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.spacing = 10
        stack.addArrangedSubview(firstNameTextField)
        stack.addArrangedSubview(surnameTextField)
        return stack
    }()

    private lazy var firstNameTextField = AuthTextField(
        viewModel: .init(
            type: .name,
            placeholderOption: .custom("First name"),
            returnKey: .continue
        )
    )
    private lazy var surnameTextField = AuthTextField(
        viewModel: .init(
            type: .name,
            placeholderOption: .custom("Surname"),
            returnKey: .done
        )
    )

    private lazy var nextButton: AuthButton = {
        let btn: AuthButton = .init(viewModel: .init(title: "Next"))
        btn.addAction(for: .touchUpInside) { [weak self] _ in
            self?.buttonAction()
        }
        return btn
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setup()
    }

    // MARK: - Private action
    private func buttonAction() {
        guard
            let validFirstName = firstNameTextField.isValidText(),
            let validSurname = surnameTextField.isValidText() else {
            return
        }
        view.endEditing(true)
        coordinator?.user.name = "\(validFirstName) \(validSurname)"
        coordinator?.goToAddBirthdayVC()
    }

    // MARK: - setup
    private func setup() {
        firstNameTextField.delegate = self
        surnameTextField.delegate = self

        contentView.addSubview(subLabel)
        contentView.addSubview(hStack)
        contentView.addSubview(nextButton)

        subLabel.anchor(
            top: contentView.topAnchor,
            width: contentView.widthAnchor
        )

        hStack.anchor(
            top: subLabel.bottomAnchor, paddingTop: 20,
            width: contentView.widthAnchor
        )

        nextButton.anchor(
            top: hStack.bottomAnchor, paddingTop: 15,
            bottom: contentView.bottomAnchor,
            width: contentView.widthAnchor
        )
    }
}

// MARK: - TextFieldDelegate
extension AddNameViewController: AuthTextFieldDelegate {
    func textFieldShouldReturn(_ textFieldView: AuthTextField) -> Bool {
        if textFieldView == firstNameTextField {
            textFieldView.textField.resignFirstResponder()
            surnameTextField.textField.becomeFirstResponder()
        } else {
            buttonAction()
        }
        return true
    }
}
