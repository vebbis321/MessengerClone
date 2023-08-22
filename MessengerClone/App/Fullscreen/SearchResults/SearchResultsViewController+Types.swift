//
//  SearchResultsViewController+Types.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/9/23.
//

import UIKit

extension SearchResultsViewController {
    // MARK: - Types
    enum Section: Int {
        case suggested = 0
        case search = 1
        case loadingSearches = 2

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
        case suggested(UserPublic)
        case search(UserPublic)
        case loadingSearches
    }

    struct SnapData {
        var key: Section
        var values: [Item]
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
}
