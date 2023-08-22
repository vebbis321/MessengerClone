//
//  InAppManager.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/23/23.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
import FireThelFirestore
import UIKit

class InAppManager {
    private var subscriptions = Set<AnyCancellable>()
    private let db = Firestore.firestore()

    init() {
        setUpBindings()
    }

    deinit {
        subscriptions.removeAll()
    }

    private func setUpBindings() {
        guard let uuid = Auth.auth().currentUser?.uid else { return }

        db.observeCollectionAndChanges(
            path: .getPath(for: .userPublic),
            predicates: [.whereField("uuid", isNotEqualTo: uuid)]
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case let .failure(err):
                print("Listener err in InappManager: \(err)")
            }
        }, receiveValue: { [weak self] listenerOutputs in
            self?.handleOutput(listenerOutputs: listenerOutputs)
        }).store(in: &subscriptions)
    }

    private func handleOutput(listenerOutputs: [ListenerOuput<UserPublic>]?) {
        guard let listenerOutputs, !listenerOutputs.isEmpty else {
            return
        }

        Task {
            await listenerOutputs.concurrentForEach({ output in
                switch output.changeType {
                case .added, .modified:
                    let user = output.data
                    var cachedUser = CachedUser(user: user)
                    try await LocalDatabase.shared.saveCachedUser(&cachedUser)

                case .removed:
                    try await LocalDatabase.shared.deleteCachedUsers(uuids: [output.data.uuid])
                }
            })

            let currentUsers = try await LocalDatabase.shared.readAll()
            // check if the cached data (LocalDatabase) has users that the actual database (Firestore) doesn't have
            let deletedUsersIds = Set(listenerOutputs.map { $0.data.uuid }).subtracting(currentUsers.map { $0.uuid })
            guard !deletedUsersIds.isEmpty else { return }
            try await LocalDatabase.shared.deleteCachedUsers(uuids: Array(deletedUsersIds))
        }
    }
}
