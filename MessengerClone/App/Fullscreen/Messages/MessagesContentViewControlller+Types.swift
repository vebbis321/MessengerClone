//
//  MessagesContentViewControlller+Types.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import Foundation

// MARK: - Types
extension MessagesContentViewController {
    enum Section: Int, CaseIterable, Hashable {
        case suggestedUsers
        case chats
    }

    enum Item: Hashable {
        case suggestedUsers(UserPublic)
        case chat(LastMessage)
    }

    struct SnapData {
        var key: Section
        var values: [Item]
    }
}
