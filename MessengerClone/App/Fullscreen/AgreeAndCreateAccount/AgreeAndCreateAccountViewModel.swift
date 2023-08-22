//
//  AgreeAndCreateAccountVM.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import Combine
import FirebaseFirestore
import FireThelFirestore
import Foundation

struct AgreeAndCreateAccountViewModel {
    // MARK: - State
    enum State {
        case idle
        case loading
        case success
        case error(MessengerError)
    }

    // MARK: - Internal properties
    var textItemViewModels: [TextItemViewModel]!
    var state = CurrentValueSubject<State, Never>(.idle)

    // MARK: - Private properties
    private let authService: AuthServiceProtocol
    private let db = Firestore.firestore()

    // MARK: - Init
    init(authService: AuthServiceProtocol) {
        self.authService = authService

        createTextItemVms()
    }

    // MARK: - Internal methods
    func createAccout(userPrivate: UserPrivate, password: String) async {
        state.send(.loading)

        // TODO: Use cloud function to do Auth and Firestore operation coherently

        do {
            let uid = try await authService.createAccounWith(email: userPrivate.email, password: password)

            let userPrivate = UserPrivate(
                uuid: uid,
                name: userPrivate.name,
                profileImageUrlString: nil,
                email: userPrivate.email,
                dateOfBirth: userPrivate.dateOfBirth
            )
            let userPublic = UserPublic(
                uuid: uid,
                name: userPrivate.name,
                profileImageUrlString: nil,
                keywords: userPrivate.name.createSubstringArray(maximumStringSize: 15)
            )

            _ = try await (
                authService.updateAuthDisplayName(uid: uid, name: userPrivate.name),
                db.createDoc(model: userPrivate, path: .getPath(for: .userPrivate), documentId: uid),
                db.createDoc(model: userPublic, path: .getPath(for: .userPublic), documentId: uid)
            )
            state.send(.success)
        } catch {
            state.send(.error(.default(error)))
        }
    }
}

// MARK: - TextItemViewModel
extension AgreeAndCreateAccountViewModel {
    struct TextItemViewModel {
        let text: String
        let tappableTextAndUrlString: [String: String]
    }

    private mutating func createTextItemVms() {
        textItemViewModels = [
            .init(
                text:
                """
                People who use our service may have uploaded your \
                contact information to Facebook. Learn more
                """,
                tappableTextAndUrlString: ["Learn more": "https://www.facebook.com/policies_center"]
            ),
            .init(
                text:
                """
                By tapping I agree, you agree to create an account \
                and to Facebook's terms. Learn how we collect, use \
                and share your data in our Privacy Policy and how we \
                use cookies and similar technology in our Cookies \
                Policy.
                """,
                tappableTextAndUrlString: [
                    "terms.": "https://www.facebook.com/policies_center",
                    "Privacy Policy": "https://www.facebook.com/policies_center",
                    "Cookies Policy.": "https://www.facebook.com/policies_center",
                ]
            ),
            .init(
                text:
                """
                The Privacy Policy describes the ways we can use the \
                information we collect when vou create an account. \
                For example, we use this information to provide. \
                personalise and improve our products, including ads.
                """,
                tappableTextAndUrlString: ["Privacy Policy": "https://www.facebook.com/policies_center"]
            ),
            .init(
                text:
                """
                You'll also receive emails from us and can opt out at \
                any time. Learn more. Learn more
                """,
                tappableTextAndUrlString: ["Learn more": "https://www.facebook.com/policies_center"]
            ),
        ]
    }
}
