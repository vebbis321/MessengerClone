//
//  SceneDelegate.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/13/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // normal
    var applicationCoordinator: ApplicationCoordinator?
    // test
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // normal
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let applicationCoordinator = ApplicationCoordinator(window: window, authService: AuthService())
        applicationCoordinator.start()
        self.applicationCoordinator = applicationCoordinator

        window.makeKeyAndVisible()

    }
}
