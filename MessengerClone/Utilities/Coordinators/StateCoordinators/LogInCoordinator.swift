//
//  LogInCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/20/23.
//

import UIKit

final class LogInCoordinator: NSObject, StateCoordinator {
    weak var parentCoordinator: ApplicationCoordinator?

    var childCoordinators: [NavCoordinator] = .init()

    var rootViewController: UINavigationController = .init()

    override init() {
        rootViewController.navigationBar.tintColor = .theme.tintColor
    }

    func start() {
        let vc = LogInViewController()
        vc.coordinator = self
        rootViewController.delegate = self
        rootViewController.pushViewController(vc, animated: false)
    }

    func startCreateAccountCoordinator() {
        let child = CreateAccountCoordinator(rootViewController: rootViewController)
        childCoordinators.append(child)
        child.parentCoordinator = self
        child.start()
    }

    deinit {
        print("✅ Deinit LogInCoordinator")
    }
}

// MARK: - UINavigationControllerDelegate
extension LogInCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow _: UIViewController, animated _: Bool) {
        // Read the view controller we’re moving from.
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        // Check whether our view controller array already contains that view controller. If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        // We’re still here – it means we’re popping the view controller, so we can check whether it’s a joinFacebookVc
        if let joinFacebookVC = fromViewController as? JoinFacebookViewController {
            // We're popping a joinFacebookVc; end its coordinator
            childDidFinish(joinFacebookVC.coordinator)
        }
    }
}
