//
//  SlideMenuViewController.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 6/16/23.
//

import SwiftUI
import UIKit

protocol SideMenuDelegate: AnyObject {
    func didTapSettings()
}

final class SideMenuViewController: UIViewController {
    // MARK: - Private Components
    private lazy var contentVC = UIHostingController(
        rootView: SideMenuView(showSettingsSheet: { [weak self] in
            self?.delegate?.didTapSettings()
        })
    )

    // MARK: - Delegate
    weak var delegate: SideMenuDelegate?

    // MARK: - Private Properties
    private let customWidth = UIScreen.main.bounds.width * 0.85
    private var topAnchorConstraint: NSLayoutConstraint!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let window = UIApplication.shared.windows.first else { return }
        let topPadding = window.safeAreaInsets.top

        topAnchorConstraint.constant = topPadding
        topAnchorConstraint.isActive = true
    }

    // MARK: - setup
    private func setup() {
        // self
        view.backgroundColor = .systemBackground

        // sideMenuVC
        addChild(contentVC)
        contentVC.didMove(toParent: self)

        view.addSubview(contentVC.view)

        let sidePadding: CGFloat = 15
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        topAnchorConstraint = contentVC.view.topAnchor.constraint(equalTo: view.topAnchor)
        contentVC.view.pinSides(to: view, padding: sidePadding)
        contentVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
