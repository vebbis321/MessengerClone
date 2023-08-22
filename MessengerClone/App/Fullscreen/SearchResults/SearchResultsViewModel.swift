//
//  SearchResultsViewModel.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/28/23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FireThelFirestore
import Foundation

protocol SearchResultsNavigatable: AnyObject {
    func tapped(user: UserPublic)
}

final class SearchResultsViewModel {
    enum State: Equatable {
        case loading
        case suggested([UserPublic])
        case search([UserPublic])
    }

    // MARK: - Private properties
    private var suggestedUsers = [UserPublic]()
    private var uid: String
    private var subscriptions = Set<AnyCancellable>()
    private let db = Firestore.firestore()

    // MARK: - Internal properties
    var searchTerm: CurrentValueSubject<String, Never> = .init("")
    var state = CurrentValueSubject<State, Never>(.loading)
    weak var navigation: SearchResultsNavigatable?

    // MARK: - LifeCycle
    init() {
        self.uid = Auth.auth().currentUser?.uid ?? ""
        subscribeToTextUpdates()
        subscribeToCachedUsersUpdates()
    }

    deinit {
        print("✅ Deinit SearchResultsViewModel")
    }

    // MARK: - Subscriptions
    private func subscribeToTextUpdates() {
        searchTerm
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { [weak self] text -> AnyPublisher<State, Never> in // we capture weak self here so we don't need the inner
                guard let self else { fatalError("Error unwrapping self") }
                if text.isEmpty {
                    return Just(.suggested(self.suggestedUsers))
                        .eraseToAnyPublisher()
                } else {
                    return Just(text)
                        .handleEvents(receiveOutput: { _ in
                            self.state.send(.loading)
                        })
                        .await({ text in
                            let users = await self.searchUsers(matching: text)
                            return .search(users)
                        })
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .assign(to: \.state.value, on: self)
            .store(in: &subscriptions)
    }

    private func subscribeToCachedUsersUpdates() {
        LocalDatabase.shared.observeSuggestedUsers()
            .map({ cachedUsers -> [UserPublic] in
                return cachedUsers.filter { $0.uuid != Auth.auth().currentUser?.uid }.map { .init(cachedUser: $0) }
            })
            .sink { completion in
                switch completion {
                case .finished:
                    print("Fin")
                case let .failure(err):
                    print(err)
                }
            } receiveValue: { [weak self] users in
                self?.suggestedUsers = users
            }.store(in: &subscriptions)
    }

    // MARK: - Private methods
    private func searchUsers(matching searchTerm: String) async -> [UserPublic] {
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
}
