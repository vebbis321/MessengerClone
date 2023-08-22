//
//  ChildControllerManagble.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/15/23.
//

import Foundation

protocol ChildControllerManagable: AnyObject {
    var childCoordinators: [NavCoordinator] { get set }
    func childDidFinish(_ child: NavCoordinator?)
}

extension ChildControllerManagable {
    func childDidFinish(_ child: NavCoordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }
}
