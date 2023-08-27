//
//  MessagesViewController.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 24/05/2023.
//

import Combine
import SwiftUI
import UIKit

final class MessagesViewController: UIViewController {
    // MARK: - Private components
    private lazy var rightBarBtn: UIBarButtonItem = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTapNewChat))
        return button
    }()

    private lazy var searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: resultVC)
        vc.showsSearchResultsController = true
        vc.searchBar.searchBarStyle = .minimal
        return vc
    }()

    private lazy var contentStateVC = ContentStateViewController()
    private lazy var contentVC: MessagesContentViewController? = nil
    private lazy var resultVC = SearchResultsViewController()
    private lazy var sideMenuVC = SideMenuViewController()

    // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: MessagesViewModel
    private var searchTerm = CurrentValueSubject<String, Never>("")
    private var mainLeftConstraint: NSLayoutConstraint!
    private var mainRightConstraint: NSLayoutConstraint!
    private let menuWidth = UIScreen.main.bounds.width * 0.85
    private let treshold: CGFloat = 500

    // MARK: - LifeCycle
    init(messagesViewModel: MessagesViewModel, searchResultsViewModel: SearchResultsViewModel) {
        self.viewModel = messagesViewModel
        super.init(nibName: nil, bundle: nil)

        resultVC.viewModel = searchResultsViewModel
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit MessagesViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    // MARK: - setup
    private func setup() {
        title = "Chats"
        view.backgroundColor = .systemBackground
        view.isExclusiveTouch = true
        view.isMultipleTouchEnabled = false

        admenuBtnForBaseTabViewContoller(action: #selector(didTapMenuBtn))

        navigationItem.rightBarButtonItem = rightBarBtn
        navigationItem.searchController = searchController

        add(contentStateVC)
    }

    // MARK: - bind
    private func bind() {
        searchController.searchBar.searchTextField.createBinding(with: resultVC.viewModel.searchTerm, storeIn: &subscriptions)

        viewModel
            .state
            .handleThreadsOperator()
            .sink { [weak self] state in
                switch state {
                case let .loaded(data):
                    self?.render(data)
                case .loading:
                    break
                case .error:
                    break
                    // handle err
                }
            }.store(in: &subscriptions)
    }

    // MARK: - Private methods
    private func render(_ data: ([LastMessage], [UserPublic])) {
        let chats = data.0
        let users = data.1

        let snapData: [MessagesContentViewController.SnapData] = [
            .init(key: .suggestedUsers, values: users.map { .suggestedUsers($0) }),
            .init(key: .chats, values: chats.map { .chat($0) }),
        ]

        if contentStateVC.shownViewController == contentVC {
            contentVC?.snapData = snapData
        } else {
            contentVC = MessagesContentViewController(snapData: snapData)
            contentVC?.delegate = self
            contentStateVC.transition(to: .render(contentVC!))
        }
    }

    private func render(_ error: MessengerError) {
        contentStateVC.transition(to: .failed(error))
    }

    // MARK: - Private actions
    @objc private func didTapNewChat() {
        viewModel.navigation?.startNewMessageFlow()
    }

    @objc private func didTapMenuBtn() {
        viewModel.navigation?.showSideMenu()
    }
}

// MARK: - MessagesContentViewControllerDelegate
extension MessagesViewController: MessagesContentViewControllerDelegate {
    func didTap(message: LastMessage) {
        Task {
            let user = try await viewModel.getUserFromMessage(message: message)
            viewModel.navigation?.tapped(user: user)
        }
    }

    func didTap(recipient: UserPublic) {
        viewModel.navigation?.tapped(user: recipient)
    }
}

// MARK: - UIGestureRecognizerDelegate
// for disabling/enabling swipe related to cell swipe and scroll
extension MessagesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        if let contentVC, contentVC.isSwipeActive || contentVC.collectionView.isDragging || contentVC.collectionView.isDecelerating {
            return false
        }

        // if user uses the scrollview, pangesture doesnt work
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: view)
            if translation.y != 0 {
                return false
            }
            return true
        }
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // pangesture can only begine when the user does a normal right scroll
        // now the collectionviewcell wont be affected by the pangesture

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: view)
            if translation.x >= 0 {
                return true
            }
            return false
        }
        return false
    }
}
