//
//  VerificationCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/15/23.
//

import UIKit

final class VerificationCoordinator: StateCoordinator {
    var childCoordinators: [NavCoordinator] = .init()

    weak var parentCoordinator: ApplicationCoordinator?

    var rootViewController: UINavigationController = .init()

    init() {
        rootViewController.navigationBar.tintColor = .theme.tintColor
    }

    func start() {
        let vc = VerifyViewController()
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: false)
    }
}
