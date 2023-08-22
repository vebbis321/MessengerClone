//
//  SettingsVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/20/23.
//

import Combine
import FirebaseAuth
import SwiftUI
import UIKit

final class SettingsVC: UIViewController {
    var subscriptions = Set<AnyCancellable>()

    weak var coordinator: SettingsCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(didTapDone))

        let childView = UIHostingController(rootView: SettingsView())
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }

    // MARK: - NavBar actions
    @objc private func didTapDone() {
        dismiss(animated: true) { [weak self] in
            self?.coordinator?.childDidFinish()
        }
    }
}
