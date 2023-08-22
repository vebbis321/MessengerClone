//
//  NewMessageCoordinator.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/11/23.
//

import UIKit

final class NewMessageCoordinator: NSObject, NavCoordinator {
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    var rootViewController: UINavigationController = .init()
    weak var parentCoordinator: MessagesTabCoordinator?
    private let viewModel = NewMessageViewModel()

    // MARK: - LifeCycle
    func start() {
        let vc = NewMessageViewController(viewModel: viewModel)
        vc.coordinator = self
        rootViewController.setViewControllers([vc], animated: false)
        rootViewController.presentationController?.delegate = self
        parentCoordinator?.rootViewController.present(rootViewController, animated: true)
    }

    deinit {
        print("✅ Deinit NewMessageCoordinator")
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension NewMessageCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_: UIPresentationController) {
        // Only called when the sheet is dismissed by DRAGGING.
        // You'll need something extra if you call .dismiss() on the child.
        // (I found that overriding dismiss in the child and calling
        // presentationController.delegate?.presentationControllerDidDismiss
        // works well).
        parentCoordinator?.childDidFinish(self)
    }
}
