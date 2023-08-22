//
//  SideMenuView+SideMenuRow.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 7/11/23.
//

import Foundation

// MARK: - SideMenuRow
extension SideMenuView {
    enum SideMenuRow: String, CaseIterable {
        case chats
        case marketplace
        case messageRequests = "Message requests"
        case archive

        var icon: String {
            switch self {
            case .chats:
                return "message.fill"
            case .marketplace:
                return "house.fill"
            case .messageRequests:
                return "ellipsis.message.fill"
            case .archive:
                return "archivebox.fill"
            }
        }
    }
}
