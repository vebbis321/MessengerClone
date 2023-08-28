//
//  VerifyVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/14/23.
//

import Combine
import FirebaseAuth
import UIKit

final class VerifyViewController: UIViewController {
    weak var coordinator: VerificationCoordinator?

    // .prepend is for firing at start instead of waiting 5 seconds for the first published value
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().prepend(Date())
    private var timerSubscription: AnyCancellable?

    // MARK: - Private Propertes
    private let viewModel = VerifyViewModel(authService: AuthService())

    // MARK: - Private Components
    private lazy var titleLabel: UILabel = .createTitleLabel(
        text: "Please verify your email",
        withAutoLayout: true
    )
    private lazy var subLabel: UILabel = .createSubLabel(
        text: "We have sent an email with a confirmation link to your email address.",
        withAutoLayout: true
    )
    private lazy var button = AuthButton(
        viewModel: .init(
            title: "I Didn't Receive the email",
            buttonType: .secondary
        )
    )
    private lazy var leftBarNavBtn: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .done,
            target: self,
            action: #selector(alreadyHaveAnAccountTapped)
        )
    }()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addObservers()
        listen()
    }

    deinit {
        removeObservers()
    }

    // MARK: - Listen
    private func listen() {
        guard timerSubscription == nil else { return }

        timerSubscription = timer
            .sink { [weak self] _ in
                self?.checkIfUserIsVerified()
            }
    }

    // MARK: - Private action
    private func checkIfUserIsVerified() {
        Task(priority: .high) {
            await viewModel.reloadUser()

            if viewModel.isEmailVerified() {
                coordinator?.parentCoordinator?.userVerifiedEmail()
            }
        }
    }

    @objc private func applicationDidBecomeActive() {
        listen()
    }

    @objc private func applicationDidEnterBackground() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    @objc private func alreadyHaveAnAccountTapped() {
        let alert = UIAlertController(
            title: "Are you sure you want to leave?",
            message: "You'll be logged out. You'll need to confirm your account the next time you log in.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Leave", style: .cancel, handler: { [weak self] _ in
            // Log out
            self?.viewModel.signOut()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            // Cancel Action
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - setup
    private func setup() {
        navigationItem.leftBarButtonItem = leftBarNavBtn
        view.backgroundColor = .theme.background
        view.addSubview(titleLabel)
        view.addSubview(subLabel)
        view.addSubview(button)

        // title
        titleLabel.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10,
            left: view.leftAnchor, paddingLeft: 20,
            right: view.rightAnchor, paddingRight: 20
        )

        subLabel.anchor(
            top: titleLabel.bottomAnchor, paddingTop: 10,
            left: view.leftAnchor, paddingLeft: 20,
            right: view.rightAnchor, paddingRight: 20
        )

        button.anchor(
            top: subLabel.bottomAnchor, paddingTop: 10,
            left: view.leftAnchor, paddingLeft: 20,
            right: view.rightAnchor, paddingRight: 20
        )
    }

    // MARK: - Observers
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
