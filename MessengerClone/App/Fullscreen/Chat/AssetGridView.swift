//
//  AssetGridView.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/26/23.
//

import UIKit

extension UIView {
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}

final class AssetGridView: UIView {
    // MARK: - Properties
    enum Section: Hashable {
        case image(hasHeader: Bool)
    }

    private var snapshot: Snapshot!
    private var dataSource: DataSource!
    private var shadowLayer: CAShapeLayer!

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Int>

    // MARK: - Components
    private lazy var handle: UIView = {
        let handle = UIView(frame: .zero)
        handle.backgroundColor = .lightGray.withAlphaComponent(0.65)
        handle.layer.masksToBounds = true
        return handle
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        configureDataSource()
        updateSnapShot(animated: false)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        handle.roundCorners(.allCorners, radius: 10)

        layer.masksToBounds = false
        layer.shadowColor = UIColor.theme.activeBorder?.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 3
        layer.cornerRadius = 10
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    // MARK: - setup
    private func setup() {
        // self
        backgroundColor = .systemBackground
        addSubview(handle)
        addSubview(collectionView)

        // handle
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        handle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        handle.widthAnchor.constraint(equalToConstant: 40).isActive = true
        handle.heightAnchor.constraint(equalToConstant: 4).isActive = true

        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 8).isActive = true
        collectionView.pinSides(to: self)
        let constraint = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }

    // MARK: - Functions
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { fatalError() }
            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            let sectionLayout: NSCollectionLayoutSection = .createImageGridLayout()
            switch section {
            case let .image(hasHeader: hasHeader):
                if hasHeader {
                    sectionLayout.boundarySupplementaryItems = [
                        .init(
                            layoutSize: .init(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .estimated(40)
                            ),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        ),
                    ]
                }
            }
            return sectionLayout
        }
        return layout
    }

    private func configureDataSource() {
        // headerRegistration
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, _, indexPath in
            guard let self else { fatalError() }
            let header = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            // Section has headerText
            switch header {
            case let .image(hasHeader: hasHeader):
                if hasHeader {
                    var configuration = headerView.defaultContentConfiguration()
                    configuration.text = "je"

                    // Customize header appearance to make it more eye-catching
                    configuration.textProperties.font = .preferredFont(forTextStyle: .callout)
                    configuration.textProperties.color = .secondaryLabel
                    configuration.directionalLayoutMargins = .init(top: 0, leading: 0.0, bottom: 5.0, trailing: 0.0)
                    configuration.textProperties.alignment = .natural

                    // Apply the configuration to header view
                    headerView.contentConfiguration = configuration
                }
            }
        }

        // mediaCell
        let mediaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Int> { cell, _, _ in
            cell.contentView.backgroundColor = .red
        }

        // dataSource init
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, model in
            return collectionView.dequeueConfiguredReusableCell(using: mediaCellRegistration, for: indexPath, item: model)
        }

        // supplementary views
        dataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath -> UICollectionReusableView? in
            guard let self else {
                return nil
            }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            switch section {
            case let .image(hasHeader):
                if hasHeader {
                    return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
                } else {
                    return nil
                }
            }
        }
    }

    private func updateSnapShot(animated: Bool = true) {
        snapshot = Snapshot()
        snapshot.appendSections([.image(hasHeader: false)])
        snapshot.appendItems([0, 1, 2, 3, 4, 5, 6, 7, 8], toSection: .image(hasHeader: false))

        dataSource.apply(snapshot, animatingDifferences: animated)

        print("Number of sections visible: \(dataSource.numberOfSections(in: collectionView))")
    }
}

extension AssetGridView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
        // select/unselect image
    }
}

extension AssetGridView: UICollectionViewDataSourcePrefetching {
    func collectionView(_: UICollectionView, prefetchItemsAt _: [IndexPath]) {
        // prefetch data(PHAsset's)
    }
}
