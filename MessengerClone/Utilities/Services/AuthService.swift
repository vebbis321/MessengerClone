//
//  AuthService.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/1/23.
//

import Combine
import FirebaseAuth
import Foundation

/// Methods for Firebase Auth.
protocol AuthServiceProtocol {
    /// Signs out.
    func signOut() throws

    /// Signs in with email and password.
    /// - Parameters:
    ///   - email:
    ///   - password:
    func signIn(email: String, password: String) async throws

    /// Reloads the current user account. Useful if the user has made Auth changes that hasn't taken place.
    func reloadUser() async throws

    /// Creates account with email and password.
    /// - Parameters:
    ///   - email:
    ///   - password:
    /// - Returns: Firebase UID
    func createAccounWith(email: String, password: String) async throws -> String

    /// Listens to the current Auth state of the user and returns the state.
    ///
    ///  - Returns: Publisher with  output ``SessionState`` and failure ``Never``
    func observeAuthChanges() -> AnyPublisher<SessionState, Never>

    func updateAuthDisplayName(uid: String, name: String) async throws
}

enum SessionState: Equatable {
    case signedOut
    case signedInButNotVerified
    case signedIn
}

final class AuthService: AuthServiceProtocol {
    // MARK: - Create Account
    func createAccounWith(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        return result.user.uid
    }

    // MARK: - Update Account
    func updateAuthDisplayName(uid _: String, name: String) async throws {
        let change = Auth.auth().currentUser?.createProfileChangeRequest()
        change?.displayName = name
        try await change?.commitChanges()
        try await Auth.auth().currentUser?.reload()
    }

    // MARK: - SigIn
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    // MARK: - SignOut
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Reload
    func reloadUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }

    // MARK: - Observe
    func observeAuthChanges() -> AnyPublisher<SessionState, Never> {
        return Publishers.AuthPublisher().eraseToAnyPublisher()
    }
}
