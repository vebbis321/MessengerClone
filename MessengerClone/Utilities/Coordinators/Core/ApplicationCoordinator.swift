//
//  ApplicationCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/13/23.
//

import Combine
import UIKit

final class ApplicationCoordinator: Coordinator {
    var rootViewController: UINavigationController = .init()

    var childCoordinators: [StateCoordinator] = [StateCoordinator]()

    private let window: UIWindow

    private var authService: AuthServiceProtocol

    private var cancellables = Set<AnyCancellable>()
    @Published private var session: SessionState = .signedOut

    // MARK: - Init
    init(window: UIWindow, authService: AuthServiceProtocol) {
        self.window = window
        self.authService = authService
    }

    // MARK: - Setup / listen
    func start() {
        window.rootViewController = LaunchViewController()
        bindAuthChangesToSession() // bind to session so we can change the state when user verified email

        $session
            .handleThreadsOperator()
            .map({ [weak self] state -> AnyPublisher<SessionState, Never> in
                if let splash = self?.window.rootViewController as? LaunchViewController {
                    // if app loads completely new scene wait for splash
                    return Just(state)
                        .delay(
                            for: .seconds(splash.countDown),
                            scheduler: RunLoop.main
                        ) // if the service is faster than the splash screen, the splash screen is still visible for its remaining time
                        .eraseToAnyPublisher()

                } else {
                    return Just(state)
                        .eraseToAnyPublisher()
                }
            })
            .switchToLatest() // cancel the current stream if we receive a new one
            .sink { [weak self] state in
                self?.setUpCoordinator(with: state)
            }.store(in: &cancellables)
    }

    // MARK: - Private methods
    private func setUpCoordinator(with state: SessionState) {
        var childCoordinator: StateCoordinator?

        switch state {
        case .signedOut:
            let coordinator = LogInCoordinator()
            window.rootViewController = coordinator.rootViewController
            childCoordinator = coordinator

        case .signedInButNotVerified:
            let coordinator = VerificationCoordinator()
            window.rootViewController = coordinator.rootViewController
            childCoordinator = coordinator

        case .signedIn:

            let coordinator = InAppCoordinator()
            // if you want you can do setup before tab bar with a loading screen
            // window.rootViewController = LoadingViewController()
            // do some delay...
            window.rootViewController = coordinator.rootViewController
            childCoordinator = coordinator
        }

        guard let childCoordinator else { return }
        childCoordinator.parentCoordinator = self
        childCoordinator.start()
        childCoordinators.removeAll()
        childCoordinators.append(childCoordinator)
    }

    // MARK: - bind
    private func bindAuthChangesToSession() {
        authService
            .observeAuthChanges()
            .assign(to: &$session)
    }

    // MARK: - Internal methods
    func userVerifiedEmail() {
        session = .signedIn
    }

    deinit {
        print("✅ Deinit ApplicationCoordinator")
    }
}
