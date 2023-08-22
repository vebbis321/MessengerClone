//
//  NavCoordinator.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/15/23.
//

import UIKit

protocol NavCoordinator: Coordinator {
    var rootViewController: UINavigationController { get set }
}
