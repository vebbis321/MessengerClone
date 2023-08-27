//
//  SignUpVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/13/23.
//

import Combine
import UIKit

final class LogInViewController: UIViewController {
    // MARK: - Private components
    private lazy var containerView = UIView(withAutolayout: true)

    private lazy var messengerImageView: UIImageView = .init(named: "Icon")

    private lazy var vStack: UIStackView = {
        let stack: UIStackView = .init(arrangedSubviews: [emailTextField, passwordTextField, loginBtn, forgotPasswordBtn])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let emailTextField = AuthTextField(
        viewModel: .init(
            type: .email,
            placeholderOption: .custom("Mobile number or email address"),
            returnKey: .continue
        )
    )
    private let passwordTextField = AuthTextField(
        viewModel: .init(
            type: .password,
            placeholderOption: .custom("Password"),
            returnKey: .done
        )
    )

    private lazy var loginBtn: AuthButton = {
        let btn = AuthButton(viewModel: .init(title: "Log in"))
        btn.addTarget(self, action: #selector(login), for: .touchUpInside)
        return btn
    }()

    private lazy var forgotPasswordBtn: UIButton = {
        let btn: UIButton = .createTextButton(with: "Forgotten Password?")
        btn.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        return btn
    }()

    private lazy var secondaryButton: UIButton = {
        let btn: UIButton = .createSecondaryButton(with: "Create new account")
        btn.addTarget(self, action: #selector(goToCreateNewAccount), for: .touchUpInside)
        return btn
    }()

    private lazy var metaImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "MetaLogo")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .theme.metaLogo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Private properties
    private let viewModel = LoginViewModel(authService: AuthService())
    private var subscriptions = Set<AnyCancellable>()
    private var keyboardPublisher: AnyCancellable?
    private var flowLayoutConstraint: NSLayoutConstraint!

    // MARK: - Internal properties
    weak var coordinator: LogInCoordinator?

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setup()

        viewModel.state
            .handleThreadsOperator()
            .sink { [weak self] currentState in
                guard let self else { return }
                switch currentState {
                case .loading:
                    self.loginBtn.isLoading = true
                case .success:
                    self.loginBtn.isLoading = false
                case let .error(err):
                    self.loginBtn.isLoading = false
                    self.alert(message: err.localizedDescription, title: "Error")
                }
            }.store(in: &subscriptions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if keyboardPublisher == nil {
            keyboardPublisher = keyboardListener()
                .sink(receiveValue: { [weak self] keyboard in
                    switch keyboard.state {
                    case .willShow:
                        self?.manageKeyboardChange(height: keyboard.height)
                    case .willHide:
                        self?.manageKeyboardChange(height: 0)
                    }
                })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardPublisher = nil
        keyboardPublisher?.cancel()
    }

    // MARK: - Private actions
    @objc private func login() {
        Task {
            await viewModel.logIn(email: emailTextField.textField.text, password: passwordTextField.textField.text)
        }
    }

    @objc private func forgotPassword() {
        // TODO: Create forgot password flow after first release
    }

    @objc private func goToCreateNewAccount() {
        coordinator?.startCreateAccountCoordinator()
    }

    // MARK: - Private methods
    private func manageKeyboardChange(height: CGFloat) {
        let bottomPadding: CGFloat = 20

        if height != 0 {
            flowLayoutConstraint.constant = (height - (view.frame.height - vStack.frame.maxY)) - bottomPadding
        } else {
            flowLayoutConstraint.constant = height
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - setup
    private func setup() {
        view.backgroundColor = .theme.background

        emailTextField.delegate = self
        passwordTextField.delegate = self

        view.addSubview(containerView)
        containerView.addSubview(messengerImageView)
        containerView.addSubview(vStack)
        containerView.addSubview(secondaryButton)
        containerView.addSubview(metaImageView)

        let padding: CGFloat = 20
        let spacingSize: CGFloat = view.bounds.height * 0.115
        let imageSize = view.bounds.height * 0.07

        flowLayoutConstraint = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        flowLayoutConstraint.isActive = true

        containerView.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            left: view.leftAnchor,
            paddingLeft: padding,
            right: view.rightAnchor,
            paddingRight: padding
        )

        messengerImageView.anchor(
            top: containerView.topAnchor,
            paddingTop: spacingSize,
            heightConstant: imageSize,
            widthConstant: imageSize,
            centerX: containerView.centerXAnchor
        )

        vStack.anchor(
            top: messengerImageView.bottomAnchor,
            paddingTop: spacingSize,
            left: containerView.leftAnchor,
            right: containerView.rightAnchor
        )

        metaImageView.anchor(
            bottom: containerView.bottomAnchor,
            heightConstant: 12,
            centerX: containerView.centerXAnchor
        )

        secondaryButton.anchor(
            bottom: metaImageView.topAnchor,
            paddingBottom: 15,
            left: containerView.leftAnchor,
            right: containerView.rightAnchor
        )
    }
}

// MARK: - TextFieldDelegate
extension LogInViewController: AuthTextFieldDelegate {
    func textFieldShouldReturn(_ textField: AuthTextField) -> Bool {
        if textField == emailTextField {
            textField.textField.resignFirstResponder()
            passwordTextField.textField.becomeFirstResponder()
        } else {
            // login
            login()
        }
        return true
    }
}
