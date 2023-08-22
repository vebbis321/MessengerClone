//
//  NameContainerView.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/12/23.
//

import UIKit

protocol NameTagViewDelegate: AnyObject {
//    var selectedUsers: [UserPublic] { get set }
    func deleteTappedName(user: UserPublic)
    func textFieldDidChange(text: String)
}

final class NameTagView: UIView {

    // MARK: - Private components
    private lazy var toLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.text = "To:"
        label.backgroundColor = .clear
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()

    private lazy var topContainer: UIView = .init(frame: .zero)

    private lazy var bottomContainer: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .horizontal
        return stack
    }()

    private lazy var containerStack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()

    // MARK: - Internal components
    lazy var searchTextField: UITextField = {
        let txtField = UITextField(frame: .zero)
        txtField.placeholder = "Search"
        txtField.textColor = .label
        txtField.textAlignment = .left
        txtField.font = .systemFont(ofSize: 15, weight: .regular)
        txtField.backgroundColor = .clear
        txtField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return txtField
    }()

    // MARK: - Properties
    private var dataSource: DataSource!
    private var snapshot: Snapshot!

    weak var delegate: NameTagViewDelegate?
    var collectionViewHeightConstraint: NSLayoutConstraint!

    // MARK: - LifeCycle
    init() {
        super.init(frame: .zero)
        setup()
        configureDatSource()
        updateSnapShot(selectedUsers: [])
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit NameContainerView")
    }

    // MARK: - setup
    private func setup() {
        backgroundColor = .theme.searchBackground

        bottomContainer.isHidden = true
        bottomContainer.alpha = 0.0
        bottomContainer.addArrangedSubview(toLabel)
        bottomContainer.addArrangedSubview(collectionView)

        containerStack.addArrangedSubview(topContainer)
        containerStack.addArrangedSubview(bottomContainer)

        addSubview(containerStack)
        topContainer.addSubview(searchTextField)

        translatesAutoresizingMaskIntoConstraints = false

        collectionViewHeightConstraint = bottomContainer.heightAnchor.constraint(equalToConstant: 33)

        searchTextField.pin(to: topContainer)

        containerStack.anchor(
            top: topAnchor, paddingTop: 10,
            bottom: bottomAnchor, paddingBottom: 10,
            left: leftAnchor, paddingLeft: 15,
            right: rightAnchor, paddingRight: 15
        )
    }

    // MARK: - Private actions
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(text: textField.text ?? "")
    }

    // MARK: - CollectionView layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            return .createDynamicWidthLayout()
        }
        return layout
    }

    // MARK: - CollectionView dataSource
    private func configureDatSource() {
        // btnCell
        let tagCellRegistration = UICollectionView.CellRegistration<NameTagCell, UserPublic> { [weak self] cell, _, model in
            cell.text = model.name
            cell.action = { [weak self] in
                self?.delegate?.deleteTappedName(user: model)
            }
        }

        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, model in
            return collectionView.dequeueConfiguredReusableCell(using: tagCellRegistration, for: indexPath, item: model)
        })
    }

    // MARK: - Internal methods
    func updateView(selectedUsers: [UserPublic]) {
        updateSnapShot(selectedUsers: selectedUsers)

        // stack becomes hidden
        if !bottomContainer.isHidden, selectedUsers.isEmpty {
            UIView.animate(
                withDuration: 0.45,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.bottomContainer.isHidden = true
                    self.bottomContainer.alpha = 0.0
                }
            )
        } else if bottomContainer.isHidden, !selectedUsers.isEmpty {
            UIView.animate(
                withDuration: 0.72,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.bottomContainer.isHidden = false
                    self.bottomContainer.alpha = 1.0
                    self.collectionViewHeightConstraint.isActive = true
                }, completion: { _ in
                    self.containerStack.layoutIfNeeded()
                }
            )
        } else {
            collectionViewHeightConstraint.constant = collectionView.contentSize.height
            collectionViewHeightConstraint.isActive = true
        }
    }

    // MARK: - Private methods
    @MainActor
    private func updateSnapShot(selectedUsers: [UserPublic], animated: Bool = true) {
        snapshot = Snapshot()
        snapshot.appendSections([.names])
        snapshot.appendItems(selectedUsers, toSection: .names)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
