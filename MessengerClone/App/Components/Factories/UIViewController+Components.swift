//
//  UIViewController+Components.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/11/23.
//

import UIKit

extension UICollectionView {
    static func createDefaultCollectionView(frame: CGRect = .zero, layout: UICollectionViewLayout) -> UICollectionView {
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }
}
