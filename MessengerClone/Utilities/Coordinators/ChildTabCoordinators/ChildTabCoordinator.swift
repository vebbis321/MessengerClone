//
//  ChildTabCoordinator.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/15/23.
//

import Foundation

protocol ChildTabCoordinator: NavCoordinator, ChildControllerManagable {
    var parentCoordinator: InAppCoordinator? { get set }
}
