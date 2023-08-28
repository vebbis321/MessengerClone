//
//  NewMessageViewModel.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/11/23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FireThelFirestore

final class NewMessageViewModel {
    // MARK: - Properties
    var eventSubject: PassthroughSubject<Event, Never> = .init()
    var userActionSubject: PassthroughSubject<Action, Never> = .init()
    @Published var statePublisher: State = .loading

    var suggestedUsers = [UserPublic]()
    var selectedUsers = [UserPublic]()
    var searchTerm: CurrentValueSubject<String, Never> = .init("")
    private let db = Firestore.firestore()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - LifeCycle
    init() {
        subscribeToUserActions()
        subscribeToEvents()
        subscripbeToTextUpdates()
        subscribeToCachedUsersUpdates()
    }

    deinit {
        print("✅ Deinit NewMessageViewModel")
    }

    // MARK: - Subscriptions
    private func subscribeToUserActions() {
        userActionSubject
            .handleEvents(receiveOutput: { [weak self] action in
                self?.updatePropertitesWith(action: action)
            })
            .map { [weak self] action in
                return self?.transform(action: action) ?? .suggestedUsers([])
            }.assign(to: &$statePublisher)
    }

    private func subscribeToEvents() {
        eventSubject
            .handleEvents(receiveOutput: { [weak self] event in
                self?.updatePropertitesWith(event: event)
            })
            .map { [weak self] event in
                self?.transform(event: event) ?? .suggestedUsers([])

            }.assign(to: &$statePublisher)
    }

    private func subscripbeToTextUpdates() {
        searchTerm
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { [unowned self] text -> AnyPublisher<State?, Never> in
                if text.isEmpty {
                    return Just(self.transform(event: .textBecameEmpty))
                        .eraseToAnyPublisher()
                } else {
                    return Just(text)
                        .handleEvents(receiveOutput: { [weak self] _ in
                            self?.statePublisher = .loading
                        })
                        .await({ value in
                            let result = await self.searchUsers(matching: value)
                            return .searchResults(result)

                        })
                }
            }
            .compactMap { $0 }
            .assign(to: &$statePublisher)
    }

    private func subscribeToCachedUsersUpdates() {
        LocalDatabase.shared.observeSuggestedUsers()
            .map({ cachedUsers -> [UserPublic] in
                return cachedUsers.filter { $0.uuid != Auth.auth().currentUser?.uid }.map { .init(cachedUser: $0) }
            })
            .sink { _ in

            } receiveValue: { [weak self] users in
                self?.eventSubject.send(.updatedSugestedUsers(users))
            }.store(in: &subscriptions)
    }

    // MARK: - Update Properties
    private func updatePropertitesWith(action: Action) {
        switch action {
        case let .tapRow(user):
            if let idx = selectedUsers.firstIndex(where: { $0.uuid == user.uuid }) {
                selectedUsers.remove(at: idx)
            } else {
                selectedUsers.append(user)
            }
            searchTerm.value = ""
        }
    }

    private func updatePropertitesWith(event: Event) {
        switch event {
        case let .updatedSugestedUsers(updatedUsers):
            suggestedUsers = updatedUsers
        default: break
        }
    }

    // MARK: - TRANSFORM
    private func transform(action: Action) -> State {
        switch statePublisher {
        case .chat, .searchResults, .suggestedUsers:
            switch action {
            case .tapRow:
                return getStateForSelection()
            }

        case .error:
            return .loading

        default:
            switch action {
            case .tapRow:
                return getStateForSelection()
            }
        }
    }

    private func transform(event: Event) -> State? {
        var state: State?

        switch statePublisher {
        case .suggestedUsers:
            switch event {
            case .updatedSugestedUsers:
                state = .suggestedUsers(suggestedUsers)

            case .textBecameEmpty:
                state = getStateForSelection()
            }

        case .loading:
            switch event {
            case .updatedSugestedUsers:
                state = .suggestedUsers(suggestedUsers)

            case .textBecameEmpty:
                state = getStateForSelection()
            }

        case .error:
            return .loading

        case .searchResults:
            if event == .textBecameEmpty {
                state = getStateForSelection()
            }

        default:
            state = statePublisher
        }

        return state
    }

    // MARK: - Private methods
    private func getStateForSelection() -> State {
        if selectedUsers.isEmpty {
            return .suggestedUsers(suggestedUsers)
        } else {
            return .chat(selectedUsers[0])
        }
    }

    private func searchUsers(matching searchTerm: String) async -> [UserPublic] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        do {
            let result: [UserPublic] = try await db.getDocs(
                path: .getPath(for: .userPublic),
                predicates: [
                    .whereField("uuid", isNotEqualTo: uid),
                    .whereField("keywords", arrayContains: searchTerm.lowercased()),
                    .limit(to: 5),
                ]
            )
            return result

        } catch {
            print(error)
            return []
        }
    }

    func userDid(_ action: Action) {
        userActionSubject.send(action)
    }
}
