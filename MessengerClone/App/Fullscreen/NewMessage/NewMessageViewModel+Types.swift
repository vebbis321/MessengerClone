//
//  NewMessageViewModel+State.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/6/23.
//

import Foundation

extension NewMessageViewModel {
    enum Event: Equatable {
        case updatedSugestedUsers([UserPublic])
        case textBecameEmpty
    }

    enum Action {
        case tapRow(UserPublic)
    }

    enum State: Equatable {
        private var value: String? {
            return String(describing: self).components(separatedBy: "(").first
        }

        static func == (lhs: State, rhs: State) -> Bool {
            lhs.value == rhs.value
        }

        case loading
        case searchResults([UserPublic])
        case suggestedUsers([UserPublic])
        case chat(UserPublic)
        case error(MessengerError)
    }
}
