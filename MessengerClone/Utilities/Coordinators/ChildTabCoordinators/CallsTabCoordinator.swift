//
//  CallsTabCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import UIKit

final class CallsTabCoordinator: ChildTabCoordinator {
    var childCoordinators: [NavCoordinator] = .init()

    weak var parentCoordinator: InAppCoordinator?

    var rootViewController: UINavigationController = .init()

    func start() {
        let vc = CallsVC()
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: false)
    }
}
