//
//  VerifyViewModel.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import FirebaseAuth
import Foundation

final class VerifyViewModel {
    private var authService: AuthServiceProtocol
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            print(error)
        }
    }

    @MainActor
    func reloadUser() async {
        do {
            try await authService.reloadUser()
        } catch {
            print(error)
        }
    }

    func isEmailVerified() -> Bool {
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            return true
        } else {
            return false
        }
    }
}
