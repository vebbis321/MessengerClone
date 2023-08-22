//
//  ChatsTabCoordinator.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import UIKit

final class MessagesTabCoordinator: ChildTabCoordinator {
    var childCoordinators: [NavCoordinator] = .init()

    weak var parentCoordinator: InAppCoordinator?

    var rootViewController: UINavigationController = .init()

    private var suggestedUsers: [UserPublic] = []

    func start() {
        let viewModel = MessagesViewModel()
        viewModel.navigation = self

        let searchResultsViewModel = SearchResultsViewModel()
        searchResultsViewModel.navigation = self

        let vc = MessagesViewController(messagesViewModel: viewModel, searchResultsViewModel: searchResultsViewModel)
        rootViewController.pushViewController(vc, animated: false)
    }
}

// MARK: - MessagesNavigatable, SearchResultsNavigatable
extension MessagesTabCoordinator: MessagesNavigatable, SearchResultsNavigatable {
    func tapped(user: UserPublic) {
        let vc = ChatViewController(recipient: user)
        vc.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(vc, animated: true)
    }

    func startNewMessageFlow() {
        let child = NewMessageCoordinator()
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showSideMenu() {
        parentCoordinator?.showSideMenu()
    }
}
