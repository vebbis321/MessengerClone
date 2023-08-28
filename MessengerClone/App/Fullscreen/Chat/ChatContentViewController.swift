//
//  ChatContentViewControllerFinal.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 6/24/23.
//

import UIKit

final class BackgroundSupplementaryView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ChatContentDelegate: AnyObject {
    func sendMessage(_ message: String)
}

class ChatContentViewController: UIViewController {
    // MARK: - Private components / views
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = nil
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var messageBar = MessageBarView(withAutolayout: true)
    private lazy var assetGrdiView = AssetGridView(withAutolayout: true)

    // acts as the frame for the keyboard and assetgridview depending on the state
    private lazy var wrapperView: UIView = .init(withAutolayout: true)

    // MARK: - Private properties
    private var messageBarViewModel: MessageBarViewModel
    private var keyboardHeight: CGFloat
    private var wrapperHeightConstraint: NSLayoutConstraint!
    private var snapshot: Snapshot!
    private var dataSource: DataSource!

    private(set) var wrapperState: WrapperState = .hidden {
        didSet {
            stateChanged(to: wrapperState)
        }
    }

    // MARK: - Internal properties
    var didAppear = false
    weak var delegate: ChatContentDelegate?

    var data: [SnapData] = [] {
        didSet {
            updateSnapShot()
        }
    }

    // MARK: - LifeCycle
    init(keyboardHeight: CGFloat) {
        self.keyboardHeight = keyboardHeight
        self.messageBarViewModel = .init(keyboardHeight: keyboardHeight)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        configureDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        wrapperState = messageBarViewModel.getState()
        collectionView.scrollToBottom(animated: true)
        didAppear = true
    }

    private func setup() {
        messageBar.messageBarBtnsDelegate = self
        messageBar.textFieldDelegate = self
        messageBar.sendAble = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        view.addSubview(messageBar)
        view.addSubview(wrapperView)

        wrapperView.addSubview(assetGrdiView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideAll))
        view.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            wrapperView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wrapperView.leftAnchor.constraint(equalTo: view.leftAnchor),
            wrapperView.rightAnchor.constraint(equalTo: view.rightAnchor),

            messageBar.bottomAnchor.constraint(equalTo: wrapperView.topAnchor),
            messageBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            messageBar.rightAnchor.constraint(equalTo: view.rightAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: messageBar.topAnchor),
        ])

        wrapperHeightConstraint = wrapperView.heightAnchor.constraint(equalToConstant: keyboardHeight)
        wrapperView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        wrapperHeightConstraint.isActive = true

        messageBar.pinSides(to: view)
        assetGrdiView.pin(to: wrapperView)
    }

    // MARK: - Internal methods
    @objc func hideAll() {
        guard !messageBarViewModel.wrapperIsInactive() else { return }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        messageBarViewModel.keyboardState = .hidden
        messageBarViewModel.assetGridState = .hidden
        messageBarViewModel.keepWrapperActive = false
        wrapperState = messageBarViewModel.getState()
    }

    func keyboardBecameActive(height: CGFloat) {
        if keyboardHeight == .zero {
            keyboardHeight = height
            wrapperHeightConstraint.constant = height
        }
        messageBarViewModel.assetGridState = .hidden
        messageBarViewModel.keyboardState = .show
        wrapperState = messageBarViewModel.getState()
    }

    func keyboardBecameHidden() {
        guard messageBarViewModel.keepWrapperActive == false else { return }
        messageBarViewModel.keyboardState = .hidden
        wrapperState = messageBarViewModel.getState()
    }

    // MARK: - Private methods
    private func toggleAssetGridState() {
        switch messageBarViewModel.assetGridState {
        case .hidden:
            if messageBarViewModel.keyboardState == .show {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            if keyboardHeight == .zero {
                // use the height we saved from splash screen
                keyboardHeight = CGFloat(UserDefaults.standard.keyboardHeight ?? 301) - (
                    parent?.presentingViewController?.view.safeAreaInsets.bottom != nil
                        ? parent!.presentingViewController!.view.safeAreaInsets.bottom
                        : .zero
                )
            }
            messageBarViewModel.assetGridState = .show

        case .show:
            messageBarViewModel.assetGridState = .hidden
            if messageBarViewModel.keyboardState == .show {
                messageBar.textView.becomeFirstResponder()
            }
        }
        wrapperState = messageBarViewModel.getState()
    }

    private func stateChanged(to state: WrapperState) {
        assetGrdiView.isHidden = self.messageBarViewModel.assetGridState.assetGridIsHidden
        assetGrdiView.alpha = self.messageBarViewModel.assetGridState.assetGridAlpha
        wrapperView.isHidden = state.wrapperIsHidden

        let height = state == .show ? keyboardHeight : .zero
        wrapperHeightConstraint.constant = height

        if state == .show {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.wrapperView.alpha = state.wrapperAlpha
                self.view.layoutIfNeeded()
                self.collectionView.scrollToBottom(animated: false)
            })

        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.wrapperView.alpha = state.wrapperAlpha
                UIView.performWithoutAnimation {
                    self.updateSnapShot(animated: false)
                }
                self.view.layoutIfNeeded()
            })
        }
    }

    private func updateSnapShot(animated _: Bool = true) {
        snapshot = Snapshot()
        snapshot.appendSections(data.map { $0.key })
        for datum in data {
            snapshot.appendItems(datum.values, toSection: datum.key)
        }

        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard (self?.snapshot.numberOfItems ?? 0) > 5 else { return }
            if self?.didAppear ?? false {
                self?.collectionView.scrollToBottom(animated: true)
            }
        }
    }
}

// MARK: - MessageBarBtnsDelegate
extension ChatContentViewController: MessageBarBtnsDelegate {
    func assetBtnTapped() {
        toggleAssetGridState()
    }
}

// MARK: - MessageBarTextFieldDelegate
extension ChatContentViewController: MessageBarTextFieldDelegate {
    func textViewDidBeginEditing(_: MessageBarView) {
        messageBarViewModel.keepWrapperActive = true
    }
}

// MARK: - MessageBarSendable
extension ChatContentViewController: MessageBarSendable {
    func sendMessage(text: String) {
        delegate?.sendMessage(text)
    }
}

// MARK: - UICollectionViewDelegate
extension ChatContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - CollectionView Layout
private extension ChatContentViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnv in
            guard let self else { fatalError() }

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .loadingChat:
                return .createLoadingLayout()
            case .chat:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
                listConfig.showsSeparators = false
                listConfig.headerMode = .supplementary
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnv)
                let sectionBackground = NSCollectionLayoutDecorationItem.background(
                    elementKind: "background"
                )

                section.decorationItems = [sectionBackground]
                section.interGroupSpacing = 1
                section.contentInsets = .init(top: 10, leading: 6, bottom: 10, trailing: 4)
                return section
            case .empty:
                return .createEmptyViewLayout()
            }
        }
        layout.register(BackgroundSupplementaryView.self, forDecorationViewOfKind: "background")
        return layout
    }
}

// MARK: - CollectionView DataSource
private extension ChatContentViewController {
    private func configureDataSource() {
        // headerRegistration
        let headerRegistration = UICollectionView
            .SupplementaryRegistration<UICollectionViewListCell>(
                elementKind: UICollectionView
                    .elementKindSectionHeader
            ) { [weak self] headerView, _, indexPath in
                guard let self else { fatalError() }
                let header = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                guard let item = self.dataSource.snapshot().itemIdentifiers(inSection: header).first else { return }

                // Section has headerText
                switch item {
                case let .chat(chatMessage):
                    var configuration = headerView.defaultContentConfiguration()
                    configuration.text = chatMessage.item.date.formatRelativeString()

                    // Customize header appearance to make it more eye-catching
                    configuration.textProperties.font = .preferredFont(forTextStyle: .callout)
                    configuration.textProperties.color = .secondaryLabel
                    configuration.directionalLayoutMargins = .init(top: 0, leading: 0.0, bottom: 5.0, trailing: 0.0)
                    configuration.textProperties.alignment = .center

                    // Apply the configuration to header view
                    headerView.contentConfiguration = configuration
                    headerView.backgroundView = nil
                    headerView.backgroundColor = .clear

                default:
                    break
                }
            }

        // listCell
        let chatListCellRegistration = UICollectionView.CellRegistration<
                ListCollectionViewCell<ChatMessageCellConfiguration>,
                ChatMessageItemViewModel
            > { [weak self] cell, indexPath, itemViewModel in
                guard let self else { return }

                var itemViewModel = itemViewModel
                let currentSnap = self.dataSource.snapshot()
                let section = currentSnap.sectionIdentifiers[indexPath.section]

                if indexPath.row == currentSnap.numberOfItems(inSection: section) - 1 {}

                if indexPath.row != 0 {
                    let previItem = currentSnap.itemIdentifiers(inSection: section)[indexPath.row - 1]
                    switch previItem {
                    case let .chat(prevModel):

                        if prevModel.item.fromId != itemViewModel.item.fromId {
                            itemViewModel.isPreviousMessageSentByCurrent = false
                        }
                    default:
                        break
                    }
                }

                cell.viewModel = itemViewModel
            }

        // loadingCell
        let loadingCellRegistration = UICollectionView.CellRegistration<CollectionViewLoadingCell, String> { cell, _, _ in
            cell.startAnimation()
        }

        // emptyChatCell
        let emptyChatCellRegistration = UICollectionView.CellRegistration<CollectionViewEmptyChatCell, UserPublic> { cell, _, user in
            cell.configure(model: user)
        }

        // dataSource init
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, model in

            switch model {
            case .loading:
                return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration, for: indexPath, item: "nil")

            case let .empty(user):
                return collectionView.dequeueConfiguredReusableCell(using: emptyChatCellRegistration, for: indexPath, item: user)

            case let .chat(chatModel):
                return collectionView.dequeueConfiguredReusableCell(using: chatListCellRegistration, for: indexPath, item: chatModel)
            }
        }

        // supplementary views
        dataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath -> UICollectionReusableView? in
            guard let self else {
                return nil
            }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            switch section {
            case .chat:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }
    }
}
