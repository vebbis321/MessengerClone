//
//  ChatViewController.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/15/23.
//

import Combine
import UIKit

// for standard swipe back
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}

final class ChatViewController: UIViewController {
    // MARK: - Components / Views
    private lazy var contentVC = ChatContentViewController(keyboardHeight: .zero)
    private var navBarView: NavBarProfileView

    // MARK: - Properties
    private let viewModel: ChatViewModel
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - LifeCycle
    init(recipient: UserPublic) {
        self.viewModel = .init(recipient: recipient, chatService: ChatService())
        self.navBarView = .init(viewModel: .init(chatTitle: nil, recipients: [recipient]))
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("✅ Deinit ChatViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        subscribeToState()
        addKeyboardListeners()
    }

    // MARK: - setup
    private func setup() {
        view.backgroundColor = .systemBackground

        let navBarView = UIBarButtonItem(customView: navBarView)
        let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItems = [backBtn, navBarView]

        let callBtn = UIBarButtonItem(image: UIImage(systemName: "phone.fill"), style: .plain, target: self, action: #selector(callsBtnTapped))
        let videoBtn = UIBarButtonItem(image: UIImage(systemName: "video.fill"), style: .plain, target: self, action: #selector(videoBtnTapped))
        navigationItem.rightBarButtonItems = [callBtn, videoBtn]

        contentVC.delegate = self
        add(contentVC)
    }

    // MARK: - Listeners
    private func addKeyboardListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    // MARK: - bind
    private func subscribeToState() {
        viewModel
            .stateSubject
            .handleThreadsOperator()
            .sink { [weak self] state in
                self?.handleStateChanged(with: state)
            }.store(in: &subscriptions)
    }

    // MARK: - Private Methods
    private func handleStateChanged(with state: ChatViewModel.State) {
        switch state {
        case .loading:
            contentVC.data = [.init(key: .loadingChat, values: [.loading])]

        case let .messages(messages):
            contentVC.data = messages.sorted(by: { $1.key > $0.key }).map { msgDict in
                .init(
                    key: .chat(msgDict.key),
                    values: msgDict.value.sorted(by: { $1.item.date > $0.item.date }).map { .chat($0) }
                )
            }

        case let .emptyChat(recipient):
            contentVC.data = [.init(key: .empty, values: [.empty(recipient)])]
        }
    }

    // MARK: - Private actions
    @objc private func keyboardWillAppear(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = keyboardSize.height
            contentVC.keyboardBecameActive(height: height)
        }
    }

    @objc private func keyboardWillDisappear(notification _: NSNotification) {
        contentVC.keyboardBecameHidden()
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func callsBtnTapped() {}

    @objc private func videoBtnTapped() {}
}

// MARK: - ChatContentDelegate
extension ChatViewController: ChatContentDelegate {
    func sendMessage(_ message: String) {
        Task {
            await viewModel.sendMessage(to: viewModel.recipient, message: message, messageType: .text)
        }
    }
}
