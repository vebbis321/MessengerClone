//
//  InAppCoordinator+TabBar.swift
//  MessengerClone
//
//  Created by Vebjørn Daniloff on 8/7/23.
//

import Foundation

extension InAppCoordinator {
    enum TabBar: String, CaseIterable {
        case chats = "Chats"
        case calls = "Calls"
        case people = "People"
        case stories = "Stories"

        var imageName: String {
            switch self {
            case .chats:
                return "message.fill"
            case .calls:
                return "phone.fill"
            case .people:
                return "person.2.fill"
            case .stories:
                return "rectangle.portrait.on.rectangle.portrait.fill"
            }
        }

        var tag: Int {
            switch self {
            case .chats:
                return 0
            case .calls:
                return 1
            case .people:
                return 2
            case .stories:
                return 3
            }
        }
    }
}
