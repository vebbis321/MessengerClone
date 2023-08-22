//
//  ChatViewModel.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/15/23.
//

import Combine
import FirebaseAuth
import FirebaseDatabase
import FireThelRealtimeDatabase
import UIKit

// MARK: - ViewModel
class ChatViewModel {
    enum State {
        case loading
        case messages([Date: [ChatMessageItemViewModel]])
        case emptyChat(UserPublic)
    }

    private let db = Database.database().reference()
    private var chatService: ChatServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    private var isExistingChat = false

    var stateSubject = CurrentValueSubject<State, Never>(.loading)
    var recipient: UserPublic

    init(recipient: UserPublic, chatService: ChatServiceProtocol) {
        self.recipient = recipient
        self.chatService = chatService

        subscribeToChatMessages()
    }

    // MARK: - Internal methods
    func subscribeToChatMessages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let chatRoomId: String = .getChatId(userId: userId, recipientId: recipient.uuid)

        db.observeChildNodes(path: .getPathToChatMessages(chatRoomId: chatRoomId), event: .value)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    print("Observe chat messages err: \(err)")
                }
            } receiveValue: { [weak self] messages in
                self?.handleMessages(messages)
            }.store(in: &subscriptions)
    }

    func sendMessage(to recipient: UserPublic, message: String, messageType: ChatMessageType) async {

        do {
            // one to one neChat
            try await chatService.sendMessageInOneToOneChat(
                with: recipient,
                message: message,
                messageType: messageType,
                isExistingChat: isExistingChat
            )
            isExistingChat = true

        } catch {
            print(error)
        }
    }

    // MARK: - Private methods
    private func handleMessages(_ messages: [ChatMessage]) {
        if messages.isEmpty {
            stateSubject.send(.emptyChat(recipient))
        } else {
            isExistingChat = true
            let viewmodels: [ChatMessageItemViewModel] = messages.map { .init(item: $0) }
            var grouped = viewmodels.sliced(by: [.day, .month, .year], for: \.item.date)

            grouped = grouped.mapValues { values in
                var messages = values.sorted(by: { $1.item.date > $0.item.date })
                if let row = messages.lastIndex(where: { $0.item.fromId == recipient.uuid }) {
                    messages[row].isLastMessage = true
                }
                return messages
            }
            stateSubject.send(.messages(grouped))
        }
    }

    deinit {
        print("✅ Deinit ChatViewModel")
    }
}
