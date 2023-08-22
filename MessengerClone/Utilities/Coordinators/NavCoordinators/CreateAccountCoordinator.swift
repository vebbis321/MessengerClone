//
//  CreateAccountCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//

import UIKit

final class CreateAccountCoordinator: NavCoordinator {
    weak var parentCoordinator: LogInCoordinator?

    var rootViewController: UINavigationController

    var user = UserPrivate(id: nil, uuid: "", name: "", profileImageUrlString: "", email: "", dateOfBirth: 0)
    var password: String?

    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }

    func start() {
        let vc = JoinFacebookViewController(titleStr: "Join Facebook to use\nMessenger")
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: true)
    }

    func goToAddNameVC() {
        let vc = AddNameViewController(titleStr: "What's your name?")
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: true)
    }

    func goToAddBirthdayVC() {
        let vc = AddBirthdayViewController(titleStr: "What's your date of birth?")
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: true)
    }

    func goToAddEmailVC() {
        let vc = AddEmailViewController(titleStr: "What's your email address?")
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: true)
    }

    func goToAddPasswordVC() {
        let vc = AddPasswordViewController(titleStr: "Create a password")
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: true)
    }

    func goToAgreeAndCreateAccountVC() {
        guard let password else { return }
        let vc = AgreeAndCreateAccountViewController(titleStr: "Agree to Facebook's terms and policies", password: password)
        vc.coordinator = self
        rootViewController.pushViewController(vc, animated: true)
    }

    deinit {
        print("✅ Deinit CreateAccountCoordinator")
    }
}
