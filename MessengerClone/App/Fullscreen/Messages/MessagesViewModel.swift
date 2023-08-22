//
//  MessagesViewModel.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 24/05/2023.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase
import FireThelRealtimeDatabase

protocol MessagesNavigatable: AnyObject {
    func startNewMessageFlow()
    func tapped(user: UserPublic)
    func showSideMenu()
}

final class MessagesViewModel {
    // MARK: - Internal properties
    weak var navigation: MessagesNavigatable?
    var state = PassthroughSubject<State, Never>()

    // MARK: - Private properties
    private let db = Database.database().reference()
    private var subscriptions = Set<AnyCancellable>()

    private let messagesSubject = PassthroughSubject<[LastMessage], MessengerError>()
    @Published private var rooms: [ChatRoom] = []

    // MARK: - LifeCycle
    init() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        observeState()
        checkIfChatRoomsExists()
        observeNewMessagesForChatRooms()
        observeNewChatRooms(userId: userId)
    }

    deinit {
        print("✅ Deinit MessagesViewModel")
    }

    // MARK: - Private methods
    private func checkIfChatRoomsExists() {
        Task {
            // since .childAdded will not get called if there is no rooms
            // we have to stop the loading if there is no rooms to load
            guard let uuid = Auth.auth().currentUser?.uid else { return }

            if try await db.child(.getPathToUserChats(userId: uuid)).getData().exists() == false {
                messagesSubject.send([])
            }
        }
    }

    // MARK: - Private observers
    private func observeState() {
        Publishers.CombineLatest(messagesSubject, suggestedUsersPublisher)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    print("Error combined publisher: \(err)")
                }
            } receiveValue: { [weak self] data in
                self?.state.send(.loaded(data))
            }.store(in: &subscriptions)
    }

    private func observeNewChatRooms(userId: String) {
        db.observeChildNode(path: .getPathToUserChats(userId: userId), event: .childAdded)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    print("Observe new room listener err: \(err)")
                }
            } receiveValue: { [weak self] room in
                self?.rooms.append(room)
                print("Appended room: \(room)")
            }.store(in: &subscriptions)
    }

    private func observeNewMessagesForChatRooms() {
        $rooms
            .flatMap({ rooms -> AnyPublisher<ChatRoom, Never> in // map publisher from array into new publisher sequence
                Publishers.Sequence(sequence: rooms).eraseToAnyPublisher()
            })
            .removeDuplicates()
            .flatMap { [weak self] room -> AnyPublisher<LastMessage, Error> in // map publisher from room into message
                guard let self else { fatalError("Error unwrapping self") }
                // each room now listen for the last message
                return self.db.observeChildNode(path: .getPathToLastMessgae(chatRoomid: room.chatRoomId), event: .value)
                    .eraseToAnyPublisher()
            }
            .scan([LastMessage](), { all, next in
                var messages = all
                if let idx = messages.firstIndex(where: { $0.chatRoomId == next.chatRoomId }) {
                    messages.remove(at: idx) // remove the old last message if it recieved an update
                }
                return (messages + [next]).sorted(by: { $1.timestamp < $0.timestamp }) // sort by most recent message
            })
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] messages in
                print(messages)
                self?.messagesSubject.send(messages)
            }.store(in: &subscriptions)
    }

    // MARK: - Private publishers
    private var suggestedUsersPublisher: AnyPublisher<[UserPublic], MessengerError> {
        LocalDatabase.shared.observeSuggestedUsers()
            .map({ cachedUsers -> [UserPublic] in
                return cachedUsers.filter { $0.uuid != Auth.auth().currentUser?.uid }.map { .init(cachedUser: $0) }
            })
            .mapError({ err in
                return MessengerError.default(err)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Internal methods
    func getUserFromMessage(message: LastMessage) async throws -> UserPublic {
        guard
            let userId = Auth.auth().currentUser?.uid,
            let recipientId = message.members.first(where: { $0.userId != userId })?.userId,
            let cached = try await LocalDatabase.shared.readForId(uuid: recipientId) else { throw MessengerError.someThingWentWrong }
        return UserPublic(cachedUser: cached)
    }
}

extension MessagesViewModel {
    enum State {
        case loaded(([LastMessage], [UserPublic]))
        case loading
        case error(MessengerError)
    }
}
