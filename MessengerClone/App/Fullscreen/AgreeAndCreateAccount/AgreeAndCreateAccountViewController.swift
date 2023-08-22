//
//  AgreeAndCreateAccountVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import Combine
import UIKit

final class AgreeAndCreateAccountViewController: BaseCreateAccountViewController {
    // MARK: - Private properties
    private var stateSubscription: AnyCancellable?
    private let viewModel = AgreeAndCreateAccountViewModel(authService: AuthService())

    // MARK: - Private components
    private lazy var tappableTextFields: [TappableTextView] = Array(0 ..< 4).map { _ in .init() }

    private let vStack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

    private let iAggreBtn = AuthButton(viewModel: .init(title: "I Agree"))

    // MARK: - LifeCycle
    init(titleStr: String, password _: String) {
        super.init(titleStr: titleStr)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setup()

        stateSubscription = viewModel.state
            .handleThreadsOperator()
            .sink { [weak self] currentState in
                switch currentState {
                case .idle:
                    break
                case .loading:
                    self?.parent?.view.isUserInteractionEnabled = false
                    self?.iAggreBtn.isLoading = true
                case .success:
                    self?.iAggreBtn.isLoading = false
                case .error:
                    self?.parent?.view.isUserInteractionEnabled = true
                    self?.iAggreBtn.isLoading = false
                }
            }
    }

    // MARK: - Private action
    private func createAccount() {
        Task { [weak self] in
            guard
                let self,
                let password = self.coordinator?.password,
                let user = self.coordinator?.user else { return }
            await self.viewModel.createAccout(userPrivate: user, password: password)
        }
    }

    // MARK: - setup
    private func setup() {
        // tappableTextFields
        for (index, textField) in tappableTextFields.enumerated() {
            textField.text = viewModel.textItemViewModels[index].text
            textField.addTappableTexts(viewModel.textItemViewModels[index].tappableTextAndUrlString)
            vStack.addArrangedSubview(textField)
        }

        // iAggreBtn
        iAggreBtn.addAction(for: .touchUpInside) { [weak self] _ in
            self?.createAccount()
        }

        // content
        contentView.addSubview(vStack)
        contentView.addSubview(iAggreBtn)

        vStack.anchor(
            top: contentView.topAnchor,
            left: contentView.leftAnchor,
            right: contentView.rightAnchor
        )

        iAggreBtn.anchor(
            top: vStack.bottomAnchor, paddingTop: 20,
            bottom: contentView.bottomAnchor,
            width: contentView.widthAnchor
        )
    }
}
