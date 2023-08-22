//
//  UICollectionView+Layout.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/11/23.
//

import UIKit

// MARK: - ListConfigs
extension UICollectionLayoutListConfiguration {
    static func createBaseListConfigWithSeparators() -> UICollectionLayoutListConfiguration {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        if #available(iOS 14.5, *) {
            listConfiguration.itemSeparatorHandler = { indexPath, sectionSeparatorConfiguration in
                var configuration = sectionSeparatorConfiguration
                configuration.topSeparatorVisibility = indexPath.row == 0 ? .hidden : .visible
                configuration.topSeparatorInsets.trailing = 20
                configuration.bottomSeparatorInsets.trailing = 20
                configuration.topSeparatorInsets.leading = 85
                configuration.bottomSeparatorInsets.leading = 85
                configuration.color = .separator.withAlphaComponent(0.5)
                return configuration
            }
        } else {
            // Fallback on earlier versions
        }
        return listConfiguration
    }
}

// MARK: - Layouts
extension NSCollectionLayoutSection {
    static func createLoadingLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

    static func createDynamicWidthLayout() -> NSCollectionLayoutSection {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(33)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: layoutSize.heightDimension
            ),
            subitems: [.init(layoutSize: layoutSize)]
        )
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = 8

        return section
    }

    static func createEmptyViewLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    static func createImageGridLayout() -> NSCollectionLayoutSection {
        let inset: CGFloat = 1

        // 4x4 grid
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / 4),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // padding between the items
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

        // set the group height the same size as item width, but one group covers one row
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1 / 4)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        // section padding, to add up for the sides of the view; 1 + 1 is already between the items but not outside
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

        return section
    }

    static func createSuggestedUserssProfileImageLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(60),
                heightDimension: .fractionalHeight(1)
            )
        )

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(90))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(14)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 18, bottom: 18, trailing: 18)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
}
