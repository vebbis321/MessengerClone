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

class TableViewCell<ContentConfiguration: ContentConfigurable>: UITableViewCell {
    var viewModel: ContentConfiguration.T?
    weak var delegate: ContentConfigurationDelegate?

    static func reuseIdentifier() -> String { return "GenericTableViewCell" }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = ContentConfiguration().updated(for: state)

        newConfiguration.viewModel = viewModel

        contentConfiguration = newConfiguration

        delegate?.swipeState(isOn: state.isSwiped)
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

final class DateTableViewHeaderView: UITableViewHeaderFooterView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: bounds)
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    static let reuseIdentifier = "DateTableViewHeaderView"

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    private func setup() {
        addSubview(titleLabel)
    }

    func configure(with date: Date) {
        titleLabel.text = date.formatRelativeString()
    }
}
