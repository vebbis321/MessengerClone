//
//  NewMessageViewController+types.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 30/05/2023.
//

import UIKit

extension NewMessageViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Section: Int {
        case newGroup = 0
        case suggested = 1
        case search = 2
        case loadingSearches = 3
        case chat

        var description: String? {
            switch self {
            case .suggested:
                return "Suggested"
            default:
                return nil
            }
        }
    }

    enum Item: Hashable {
        case newGroup
        case suggested(UserPublic)
        case search(UserPublic)
        case chat(UserPublic)
        case loadingSearches
    }

    struct SnapData {
        var key: Section
        var values: [Item]
    }
}
