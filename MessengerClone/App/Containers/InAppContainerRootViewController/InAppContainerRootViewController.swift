//
//  InAppContainerRootViewController.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 6/22/23.
//

import UIKit

final class InAppContainerRootViewController: UIViewController {
    weak var coordinator: InAppCoordinator?

    // MARK: - Views / Controllers
    lazy var backdropView: UIView = {
        let bdView = UIView(withAutolayout: true)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bdView.alpha = 0
        bdView.isUserInteractionEnabled = false
        bdView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        return bdView
    }()

    let mainContainerView = UIView(withAutolayout: true)
    let sideMenuContainerView = UIView(withAutolayout: true)

    // MARK: - Properties
    private var mainLeftConstraint: NSLayoutConstraint!
    private var mainRightConstraint: NSLayoutConstraint!
    private let menuWidth = UIScreen.main.bounds.width * 0.85
    private let treshold: CGFloat = 500
    var sideMenuState: SideMenuState = .closed {
        didSet {
            sideMenuStateChanged()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.addSubview(mainContainerView)
        mainContainerView.addSubview(backdropView)
        view.addSubview(sideMenuContainerView)

        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sideMenuContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            sideMenuContainerView.rightAnchor.constraint(equalTo: mainContainerView.leftAnchor),
            sideMenuContainerView.widthAnchor.constraint(equalToConstant: menuWidth),
            sideMenuContainerView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),
        ])

        mainLeftConstraint = mainContainerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        mainLeftConstraint.isActive = true

        mainRightConstraint = mainContainerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        mainRightConstraint.isActive = true

        backdropView.pin(to: mainContainerView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        backdropView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Methods
    func handleGestureChanged(gesture: UIPanGestureRecognizer) {
        var x = gesture.translation(in: view).x

        x += sideMenuState == .open ? menuWidth : 0
        x = min(menuWidth, x)
        x = max(0, x)

        mainLeftConstraint.constant = x
        mainRightConstraint.constant = x
        backdropView.alpha = x / menuWidth
    }

    func handleGestureEnded(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: view)
        let translation = gesture.translation(in: view)

        if abs(velocity.x) > treshold {
            if velocity.x > .zero {
                sideMenuState = .open
            } else {
                sideMenuState = .closed
            }
            return
        }

        switch sideMenuState {
        case .open:
            sideMenuState = abs(translation.x) < menuWidth / 2 ? .open : .closed
        case .closed:
            sideMenuState = abs(translation.x) < menuWidth / 2 ? .closed : .open
        }
    }

    // MARK: - Private Methods
    private func sideMenuStateChanged() {
        let constant = sideMenuState == .open ? menuWidth : 0
        mainLeftConstraint.constant = constant
        mainRightConstraint.constant = constant

        performAnimations()

        navigationController?.navigationBar.isUserInteractionEnabled = sideMenuState.isTabBarControllerInteractive
        mainContainerView.subviews.filter({ $0 != backdropView })
            .forEach({ $0.isUserInteractionEnabled = sideMenuState.isTabBarControllerInteractive })
        backdropView.isUserInteractionEnabled = sideMenuState.isBackDropViewInteractive
    }

    private func performAnimations() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.backdropView.alpha = self.sideMenuState == .open ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Private Action
    @objc private func handleTap(gesture _: UITapGestureRecognizer) {
        coordinator?.hideSideMenu()
    }
}

// MARK: - SideMenuDelegate
extension InAppContainerRootViewController: SideMenuDelegate {
    func didTapSettings() {
        coordinator?.startSettingsFlow()
    }
}

// MARK: - UIGestureRecognizerDelegate
// extension InAppContainerRootViewController: UIGestureRecognizerDelegate {

// }
