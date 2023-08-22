//
//  InAppTabBarController.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 6/23/23.
//

import UIKit

final class InAppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoot()
    }

    // MARK: - setup
    private func setupRoot() {
        view.clipsToBounds = false
        tabBar.backgroundColor = .systemBackground
        tabBar.barTintColor = .systemBackground
        tabBar.tintColor = .theme.button
    }
}
