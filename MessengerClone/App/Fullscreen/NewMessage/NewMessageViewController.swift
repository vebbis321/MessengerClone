//
//  NewMessageVC.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/10/23.
//
import Combine
import UIKit

final class NewMessageViewController: UIViewController {

    // MARK: - Private components
    private lazy var nameView = NameTagView()
    private lazy var collectionView: UICollectionView = .createDefaultCollectionView(layout: createLayout())

    // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private var dataSource: DataSource!
    private var snapshot: Snapshot!
    private var viewModel: NewMessageViewModel
    private var keyboardHeight: CGFloat = .zero
    private var currentSnapData = [SnapData]() {
        didSet {
            updateSnapShot()
        }
    }

    // MARK: - Internal properties
    weak var coordinator: NewMessageCoordinator?
    var parentHideKeyboard = false

    init(viewModel: NewMessageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureDataSource()
        bind()
        observeKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        nameView.searchTextField.becomeFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        parentHideKeyboard = true
        view.endEditing(true)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("✅ Deinit NewMessageViewController")
    }

    // MARK: - setup
    private func setup() {
        title = "New message"
        navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        collectionView.delegate = self
        view.backgroundColor = .systemBackground

        nameView.delegate = self

        view.addSubview(nameView)
        view.addSubview(collectionView)

        nameView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10,
            width: view.widthAnchor
        )

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.anchor(
            top: nameView.bottomAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            width: view.widthAnchor
        )
    }

    // MARK: - Listeners
    private func bind() {
        viewModel
            .$statePublisher
            .removeDuplicates(by: { prev, curr in
                prev == .loading && curr == .loading
            })
            .handleThreadsOperator()
            .sink { [weak self] state in
                guard let self else { return }

                switch state {
                case .loading:
                    self.currentSnapData.append(.init(key: .loadingSearches, values: [.loadingSearches]))

                case let .suggestedUsers(users):
                    var updateData: [SnapData] = [.init(key: .newGroup, values: [.newGroup])]
                    if !users.isEmpty {
                        updateData.append(.init(key: .suggested, values: users.map { .suggested($0) }))
                    }
                    self.currentSnapData = updateData

                case let .searchResults(users):
                    self.currentSnapData = [.init(key: .search, values: users.map { .search($0) })]

                case let .chat(recipient):
                    self.currentSnapData = [.init(key: .chat, values: [.chat(recipient)])]

                case let .error(err):
                    print(err)
                }

            }.store(in: &subscriptions)
    }

    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Private actions
    @objc private func didTapCancel() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.coordinator?.parentCoordinator?.childDidFinish(self.coordinator)
        }
    }

    @objc private func keyboardWillAppear(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let height = keyboardSize.height - (parent?.view.safeAreaInsets.bottom ?? .zero)
            keyboardHeight = height
        }
    }

    @objc private func keyboardWillDisappear(notification _: NSNotification) {
        keyboardHeight = .zero
    }

    // MARK: - CollectionView layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnv in
            guard let self else { fatalError() }

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            // loading
            case .loadingSearches:
                return .createLoadingLayout()

            // chat
            case .chat:
                return .createEmptyViewLayout()

            // lists layout
            default:
                var listConfiguration: UICollectionLayoutListConfiguration = .createBaseListConfigWithSeparators()
                // does the list has header
                if section == .suggested {
                    listConfiguration.headerMode = .supplementary
                } else {
                    listConfiguration.headerMode = .none
                }

                if section == .newGroup {
                    listConfiguration.showsSeparators = false
                }

                return .list(using: listConfiguration, layoutEnvironment: layoutEnv)
            }
        }
        return layout
    }

    // MARK: - CollectionView dataSource
    private func configureDataSource() {
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, _, indexPath in
            guard let self else { fatalError() }
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

        let createNewGroupCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, _ in
            var config = cell.defaultContentConfiguration()
            config.text = "Create a new group"
            config.textProperties.font = .systemFont(ofSize: 15, weight: .semibold)
            config.image = UIImage(named: "custom-three.people")
            config.imageProperties.maximumSize = .init(width: 40, height: 40)
            config.imageProperties.cornerRadius = 20
            config.directionalLayoutMargins.top = 10
            config.directionalLayoutMargins.bottom = 10
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
        }

        let listCellRegistration = UICollectionView
            .CellRegistration<ListCollectionViewCell<UserListCellConfiguration>, UserPublic> { [weak self] cell, _, model in
                guard let self else { return }

                cell.viewModel = model

                if self.viewModel.selectedUsers.contains(where: { $0.uuid == model.uuid }) {
                    cell.accessories = [.checkmark()]
                } else {
                    cell.accessories = []
                }
            }

        let chatViewCellRegistration = UICollectionView.CellRegistration<ChatControllerCollectionViewCell, UserPublic> { [weak self] cell, _, model in
            guard let self else { return }
            cell.configure(with: self, recipient: model, keyboardHeight: self.keyboardHeight)
        }

        let loadingCellRegistration = UICollectionView.CellRegistration<CollectionViewLoadingCell, String> { cell, _, _ in
            cell.startAnimation()
        }

        // dataSource init
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, model in

            switch model {
            case .newGroup:
                return collectionView.dequeueConfiguredReusableCell(using: createNewGroupCellRegistration, for: indexPath, item: "new")

            case let .suggested(user):
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: user)

            case let .search(user):
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: user)

            case .loadingSearches:
                return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration, for: indexPath, item: "nil")

            case let .chat(user):
                return collectionView.dequeueConfiguredReusableCell(using: chatViewCellRegistration, for: indexPath, item: user)
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

    private func userRowTapped(user: UserPublic) {
        viewModel.userDid(.tapRow(user))
        nameView.updateView(selectedUsers: viewModel.selectedUsers)
    }
}

// MARK: - UICollectionViewDelegate
extension NewMessageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        switch item {
        case let .suggested(user):
            userRowTapped(user: user)

        case let .search(user):
            userRowTapped(user: user)

        default:
            break
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - NameContainerDelegate
extension NewMessageViewController: NameTagViewDelegate {
    func textFieldDidChange(text: String) {
        viewModel.searchTerm.send(text)
    }

    func deleteTappedName(user: UserPublic) {
        userRowTapped(user: user)
    }
}
