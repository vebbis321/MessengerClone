//
//  NameTagView+Types.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import UIKit

extension NameTagView {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, UserPublic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UserPublic>

    enum Section: Int {
        case names
    }
}
