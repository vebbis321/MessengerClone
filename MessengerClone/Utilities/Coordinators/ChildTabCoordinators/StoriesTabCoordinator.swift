//
//  StoriesTabCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import UIKit

final class StoriesTabCoordinator: ChildTabCoordinator {
    weak var parentCoordinator: InAppCoordinator?

    var rootViewController: UINavigationController = .init()

    var childCoordinators: [NavCoordinator] = .init()

    func start() {
        let vc = StoriesVC()
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: false)
    }
}
