//
//  LocalDatabase.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 19/05/2023.
//

import Combine
import FirebaseAuth
import GRDB

// MARK: - init / default
struct LocalDatabase {
    private let writer: DatabaseWriter

    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        try migrator.migrate(writer)
    }

    var reader: DatabaseReader {
        writer
    }
}

// MARK: - CachedUser
struct CachedUser: Codable, FetchableRecord, MutablePersistableRecord {
    var uuid: String
    var name: String
    var profileImageUrl: String?
}

extension CachedUser {
    init(user: UserPublic) {
        self.uuid = user.uuid
        self.name = user.name
        self.profileImageUrl = user.profileImageUrlString
    }
}

// MARK: - Writes
extension LocalDatabase {
    /// Saves (inserts or updates) a cached user. When the method returns, the
    /// user is present in the database, and its id is not nil.
    func saveCachedUser(_ user: inout CachedUser) async throws {
        user = try await writer.write { [user] db in
            try user.saved(db)
        }
    }
}

// MARK: - Reads
extension LocalDatabase {
    func readAll() async throws -> [CachedUser] {
        try await reader.read({ db in
            return try CachedUser.fetchAll(db)
        })
    }

    func readForId(uuid: String) async throws -> CachedUser? {
        try await reader.read({ db in
            return try CachedUser.fetchOne(db, key: uuid)
        })
    }

    func suggestedUserDataExists() async throws -> Bool {
        try await reader.read { db in
            return try !CachedUser.fetchAll(db).isEmpty
        }
    }
}

// MARK: - Observe
extension LocalDatabase {
    func observeSuggestedUsers() -> AnyPublisher<[CachedUser], Error> {
        let observation = ValueObservation.tracking { db in
            var users = try CachedUser.fetchAll(db)
            if let idx = users.firstIndex(where: { $0.uuid == Auth.auth().currentUser?.uid }) {
                users.remove(at: idx)
            }
            return users
        }

        let publisher = observation.publisher(in: reader)
        return publisher.eraseToAnyPublisher()
    }

    func observeSuggestedUser(with uuid: String) -> AnyPublisher<CachedUser?, Error> {
        let observation = ValueObservation.tracking { db in
            try CachedUser.fetchOne(db, key: uuid)
        }

        let publisher = observation.publisher(in: reader)
        return publisher.eraseToAnyPublisher()
    }
}

// MARK: - Delete
extension LocalDatabase {
    func deleteCachedUsers(uuids: [String]) async throws {
        try await writer.write { db in
            _ = try CachedUser.deleteAll(db, keys: uuids)
        }
    }
}
