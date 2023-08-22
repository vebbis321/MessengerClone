//
//  MessagesContentViewController.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 24/05/2023.
//

import UIKit

protocol MessagesContentViewControllerDelegate: AnyObject {
    func didTap(recipient: UserPublic)
    func didTap(message: LastMessage)
}

final class MessagesContentViewController: UIViewController {
    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    // MARK: - Components
    private let searchController = UISearchController()

    private func swipeLayout(icon: String, text: String, size: CGFloat) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular, scale: .large)
        let img = UIImage(
            systemName: icon,
            withConfiguration: config
        )?.withTintColor(
            .white,
            renderingMode: .alwaysOriginal
        )

        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.text = text

        let tempView = UIStackView(frame: .init(x: 0, y: 0, width: 50, height: 50))

        let imageView = UIImageView(
            frame: .init(
                x: 0, y: 0,
                width: img?.size.width ?? size, height: img?.size.height ?? size
            )
        )
        imageView.contentMode = .scaleAspectFit
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 2
        imageView.image = img
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)

        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    private lazy var listLayoutSection: UICollectionLayoutListConfiguration = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in


            // get the model for the given index path from your data source
            let model = self?.dataSource.itemIdentifier(for: indexPath)

            // more
            let moreHandler: UIContextualAction.Handler = { action, _, completion in
                self?.presentActionSheet(dismiss: {
                    completion(true)
                })
                print(action)
            }
            let moreAction = UIContextualAction(style: .normal, title: nil, handler: moreHandler)
            moreAction.image = self?.swipeLayout(icon: "ellipsis.circle.fill", text: "More", size: 16)
            moreAction.backgroundColor = .theme.moreRow

            // archive
            let archiveHandler: UIContextualAction.Handler = { [weak self] _, _, completion in
                completion(true)
            }
            let archiveAction = UIContextualAction(style: .normal, title: nil, handler: archiveHandler)
            archiveAction.image = self?.swipeLayout(icon: "archivebox.fill", text: "Archive", size: 16)
            archiveAction.backgroundColor = .theme.arhiveRow

            return UISwipeActionsConfiguration(actions: [archiveAction, moreAction])
        }
        return listConfiguration
    }()


    // MARK: - Private properties
    private var dataSource: DataSource!
    private var snapshot: Snapshot!

    // MARK: - Internal properties
    var snapData: [SnapData] {
        didSet {
            updateSnapShot()
        }
    }

    weak var delegate: MessagesContentViewControllerDelegate?
    var isSwipeActive = false

    // MARK: - LifeCycle
    init(snapData: [SnapData]) {
        self.snapData = snapData
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit MessagesContentViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureDataSource()
        updateSnapShot(animated: true)
    }

    // MARK: - setup
    private func setup() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    // MARK: - Internal methods
    func presentActionSheet(dismiss: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Your title",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(
            title: "Your action 1",
            style: .default
        ) { _ in
            dismiss()
            // onAction1()
        })

        alert.addAction(UIAlertAction(
            title: "Your action 2",
            style: .default
        ) { _ in
            // onAction2()
            dismiss()
        })

        alert.addAction(UIAlertAction(
            title: "Your cancel action",
            style: .cancel
        ) { _ in
            // onCancel
        })

        present(alert, animated: true)
    }

    // MARK: - CollectionView layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnv in
            guard let self else { fatalError() }

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .suggestedUsers:
                return .createSuggestedUserssProfileImageLayout()

            case .chats:
                return NSCollectionLayoutSection.list(using: self.listLayoutSection, layoutEnvironment: layoutEnv)
            }
        }
        return layout
    }

    // MARK: - CollectionView dataSource
    private func configureDataSource() {
        // registrate our custom cell
        let suggestedUserCellRegistration = UICollectionView.CellRegistration<CollectionViewProfileImageCell, UserPublic> { cell, _, model in
            cell.configure(with: model)
        }

        let listCellRegistration = UICollectionView
            .CellRegistration<ListCollectionViewCell<LastMessageCellConfiguration>, LastMessage> { [weak self] cell, _, model in
                cell.delegate = self
                cell.viewModel = .init(item: model)
            }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in

            switch item {
            case let .suggestedUsers(user):
                return collectionView.dequeueConfiguredReusableCell(
                    using: suggestedUserCellRegistration,
                    for: indexPath,
                    item: user
                )
            case let .chat(message):
                return collectionView.dequeueConfiguredReusableCell(
                    using: listCellRegistration,
                    for: indexPath,
                    item: message
                )
            }
        }
    }

    @MainActor
    private func updateSnapShot(animated: Bool = true) {
        snapshot = Snapshot()
        snapshot.appendSections(snapData.map { $0.key })
        for datum in snapData {
            snapshot.appendItems(datum.values, toSection: datum.key)
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - UICollectionViewDelegate
extension MessagesContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        switch item {
        case let .suggestedUsers(user):
            delegate?.didTap(recipient: user)

        case let .chat(message):
            delegate?.didTap(message: message)
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - ContentConfigurationDelegate
extension MessagesContentViewController: ContentConfigurationDelegate {
    func swipeState(isOn: Bool) {
        isSwipeActive = isOn
    }
}
