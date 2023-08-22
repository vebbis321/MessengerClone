//
//  SearchResultVC.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/7/23.
//

import Combine
import UIKit

final class SearchResultsViewController: UIViewController {

    // MARK: - Private components
    private lazy var collectionView: UICollectionView = .createDefaultCollectionView(frame: view.bounds, layout: createLayout())
    private lazy var listConfiguration: UICollectionLayoutListConfiguration = .createBaseListConfigWithSeparators()

    // MARK: - Private properties
    private var listenerSubscriptions: AnyCancellable?
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    private var currentSnapData = [SnapData]() {
        didSet {
            updateSnapShot()
        }
    }

    // MARK: - Internal properties
    var viewModel: SearchResultsViewModel!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureDataSource()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        viewModel.searchTerm.send("")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard listenerSubscriptions == nil else { return }
        startListener()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit SearchResultsViewController")
    }

    // MARK: - setup
    private func setup() {
        view.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    // MARK: - Listeners
    private func startListener() {
        listenerSubscriptions = viewModel
            .state
            .removeDuplicates(by: { prev, curr in
                prev == .loading && curr == .loading
            })
            .handleThreadsOperator()
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.currentSnapData.append(.init(key: .loadingSearches, values: [.loadingSearches]))

                case let .suggested(users):
                    self?.currentSnapData = [.init(key: .suggested, values: users.map { .suggested($0) })]

                case let .search(users):
                    self?.currentSnapData = [.init(key: .search, values: users.map { .search($0) })]
                }
            }
    }

    // MARK: - CollectionView layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnv in
            guard let self else { fatalError("Layout error") }

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            // loading
            case .loadingSearches:
                return .createLoadingLayout()

            // lists layout
            default:
                // does the list has header
                if section == .suggested {
                    self.listConfiguration.headerMode = .supplementary
                } else {
                    self.listConfiguration.headerMode = .none
                }
                return .list(using: self.listConfiguration, layoutEnvironment: layoutEnv)
            }
        }
        return layout
    }

    // MARK: - CollectionView dataSource
    private func configureDataSource() {
        // headerCell
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, _, indexPath in
            guard let self else { fatalError("Datasource error") }
            let header = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            // Section has headerText
            if let text = Section(rawValue: header.rawValue)?.description {
                var configuration = headerView.defaultContentConfiguration()
                configuration.text = text

                // Customize header appearance to make it more eye-catching
                configuration.textProperties.font = .preferredFont(forTextStyle: .callout)
                configuration.textProperties.color = .secondaryLabel
                configuration.directionalLayoutMargins = .init(top: 0, leading: 0.0, bottom: 5.0, trailing: 0.0)

                // Apply the configuration to header view
                headerView.contentConfiguration = configuration
            }
        }

        // listCell
        let listCellRegistration = UICollectionView.CellRegistration<
            ListCollectionViewCell<UserListCellConfiguration>, UserPublic> { cell, _, model in
            cell.viewModel = model
        }

        // loadingCell
        let loadingCellRegistration = UICollectionView.CellRegistration<CollectionViewLoadingCell, String> { cell, _, _ in
            cell.startAnimation()
        }

        // dataSource init
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, model in

            switch model {
            case let .suggested(user):
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: user)

            case let .search(user):
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: user)

            case .loadingSearches:
                return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration, for: indexPath, item: "nil")
            }
        }

        // supplementary views
        dataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath -> UICollectionReusableView? in
            guard let self else {
                return nil
            }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            switch section {
            case .suggested:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }
    }

    // MARK: - Private methods
    private func updateSnapShot(animated: Bool = true) {
        snapshot = Snapshot()
        snapshot.appendSections(currentSnapData.map { $0.key })
        for datum in currentSnapData {
            snapshot.appendItems(datum.values, toSection: datum.key)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        switch item {
        case let .suggested(user):
            viewModel.navigation?.tapped(user: user)
        case let .search(user):
            viewModel.navigation?.tapped(user: user)
        default: break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// final class ResultCollectionViewListCell: UICollectionViewListCell {
//    override func updateConstraints() {
//        super.updateConstraints()
//
//        separatorLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
//    }
// }
