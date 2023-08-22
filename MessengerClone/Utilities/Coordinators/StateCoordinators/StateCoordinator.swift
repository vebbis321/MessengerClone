//
//  StateCoordinator.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/15/23.
//

import Foundation

protocol StateCoordinator: Coordinator, ChildControllerManagable {
    var parentCoordinator: ApplicationCoordinator? { get set }
}
