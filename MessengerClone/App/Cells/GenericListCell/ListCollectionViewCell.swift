//
//  ChatRoomListCell.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/25/23.
//

import UIKit

// class CustomListCell: UICollectionViewListCell {
//
//    var item: ChatRoomModel?
//
//    override func updateConfiguration(using state: UICellConfigurationState) {
//
//        var newConfiguration = ChatRoomContentConfiguration().updated(for: state)
//
//        newConfiguration.item = item
//
//        contentConfiguration = newConfiguration
//
//    }
// }

protocol ContentConfigurationDelegate: AnyObject {
    func swipeState(isOn: Bool)
}

class ListCollectionViewCell<ContentConfiguration: ContentConfigurable>: UICollectionViewListCell {
    var viewModel: ContentConfiguration.T?
    weak var delegate: ContentConfigurationDelegate?

    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = ContentConfiguration().updated(for: state)

        newConfiguration.viewModel = viewModel
        delegate?.swipeState(isOn: state.isSwiped)
        contentConfiguration = newConfiguration
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        viewModel = nil
        delegate = nil
    }

    deinit {
        viewModel = nil
        delegate = nil
    }
}
