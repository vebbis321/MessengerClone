//
//  CollectionViewControllerCell.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/6/23.
//

import Combine
import FirebaseAuth
import UIKit

final class ChatControllerCollectionViewCell: UICollectionViewCell {
    private(set) var childVC: ChatContentViewController?
    private var stateSubscription: AnyCancellable?
    private var viewModel: ChatViewModel?
    private var recipient: UserPublic?

    weak var parent: NewMessageViewController?

    // MARK: - LifeCycle
    func configure(with parent: NewMessageViewController, recipient: UserPublic, keyboardHeight: CGFloat) {
        self.parent = parent
        self.recipient = recipient
        self.viewModel = .init(recipient: recipient, chatService: ChatService())

        embed(with: keyboardHeight)
        addListeners()
        subscribeToState()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        print("prepareforreuse")
        NotificationCenter.default.removeObserver(self)
        parent = nil
        childVC?.remove()
        stateSubscription?.cancel()
        viewModel = nil
        recipient = nil
        childVC = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        parent = nil
        childVC?.remove()
        stateSubscription?.cancel()
        viewModel = nil
        recipient = nil
        childVC = nil
    }

    // MARK: - setup
    private func embed(with height: CGFloat) {
        let childVC = ChatContentViewController(keyboardHeight: height)
        childVC.delegate = self
        parent?.addChild(childVC)
        childVC.didMove(toParent: parent)
        childVC.view.frame = self.contentView.bounds
        self.contentView.addSubview(childVC.view)
        self.childVC = childVC
    }

    // MARK: - Listeners
    private func addListeners() {
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

    private func subscribeToState() {
        stateSubscription = viewModel?
            .stateSubject
            .handleThreadsOperator()
            .sink { [weak self] state in
                self?.handleNewState(with: state)
            }
    }

    // MARK: - Private Methods
    private func handleNewState(with state: ChatViewModel.State) {
        switch state {
        case .loading:
            childVC?.data = [.init(key: .loadingChat, values: [.loading])]

        case let .messages(messages):
            childVC?.data = messages.sorted(by: { $1.key > $0.key }).map { msgDict in
                .init(
                    key: .chat(msgDict.key),
                    values: msgDict.value.sorted(by: { $1.item.date > $0.item.date }).map { .chat($0) }
                )
            }

        case let .emptyChat(recipient):
            childVC?.data = [.init(key: .empty, values: [.empty(recipient)])]
        }
    }

    @objc private func keyboardWillAppear(notification: NSNotification) {
        // Do something here
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = keyboardSize.height - (parent?.view.safeAreaInsets.bottom ?? .zero)
            childVC?.keyboardBecameActive(height: height)
        }
    }

    @objc private func keyboardWillDisappear(notification _: NSNotification) {
        let parent = parent!

        if parent.parentHideKeyboard {
            childVC?.hideAll()
            parent.parentHideKeyboard = false
        } else {
            childVC?.keyboardBecameHidden()
        }
    }
}

// MARK: - ChatViewDelegate
extension ChatControllerCollectionViewCell: ChatContentDelegate {
    func sendMessage(_ message: String) {
        guard let recipient else { return }
        Task {
            await viewModel?.sendMessage(to: recipient, message: message, messageType: .text)
        }
    }
}
