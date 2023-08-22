//
//  LoginViewModel.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/20/23.
//

import Combine
import Foundation

struct LoginViewModel {
    enum State {
        case loading
        case success
        case error(MessengerError)
    }

    var state = PassthroughSubject<State, Never>()

    private let authService: AuthServiceProtocol
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func logIn(email: String?, password: String?) async {
        guard let email, let password else {
            state.send(.error(.someThingWentWrong))
            return
        }
        state.send(.loading)
        do {
            try await authService.signIn(email: email, password: password)
            state.send(.success)
        } catch {
            state.send(.error(.default(error)))
        }
    }
}
