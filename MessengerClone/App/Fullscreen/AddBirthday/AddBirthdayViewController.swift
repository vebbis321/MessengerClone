//
//  AddDateVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/22/23.
//

import UIKit

final class AddBirthdayViewController: BaseCreateAccountViewController {
    // MARK: - Private components
    private lazy var tappableSubText = TappableTextView()
    private lazy var textFieldView = AuthTextField(viewModel: .init(type: .date))
    private lazy var nextBtn = AuthButton(viewModel: .init(title: "Next"))

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setup()
    }

    // MARK: - setup
    private func setup() {
        // tappableSubText
        let clickText = "Why do I need to provide my date of birth?"
        tappableSubText.text = "Choose your date of birth. You can always make this private later. \(clickText)"
        tappableSubText.addTappableTexts([clickText: nil])
        tappableSubText.onTextTap = { [weak self] in
            let slideVC = BottomSheetViewController(customView: BirthdaysInfoView())
            slideVC.modalPresentationStyle = .custom
            self?.present(slideVC, animated: true)
            return false
        }

        // nextBtn
        nextBtn.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self else { return }
            self.coordinator?.user.dateOfBirth = self.textFieldView.datePicker.date.unixTimestamp
            self.coordinator?.goToAddEmailVC()
        }

        view.addSubview(tappableSubText)
        view.addSubview(textFieldView)
        view.addSubview(nextBtn)

        tappableSubText.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor
        )

        textFieldView.anchor(
            top: tappableSubText.bottomAnchor, paddingTop: 20,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor
        )

        nextBtn.anchor(
            top: textFieldView.bottomAnchor, paddingTop: 15,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor
        )
    }
}
