//
//  ChatView+Types.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 6/24/23.
//

import UIKit

extension ChatContentViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias Timestamp = Int

    enum Section: Hashable {
        case loadingChat
        case empty
        case chat(Date)
    }

    enum Item: Hashable {
        case loading
        case empty(UserPublic)
        case chat(ChatMessageItemViewModel)
    }

    struct SnapData {
        var key: Section
        var values: [Item]
    }
}
