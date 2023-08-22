//
//  CustomModalVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/27/23.
//

import UIKit

final class BottomSheetViewController: UIViewController {
    // MARK: - Private Components
    private lazy var backdropView: UIView = {
        let bdView = UIView(frame: view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()

    private lazy var modalContainerView: UIView = {
        let view = UIView(withAutolayout: true)
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    private lazy var handle: UIView = {
        let handle = UIView(withAutolayout: true)
        handle.backgroundColor = .lightGray.withAlphaComponent(0.65)
        handle.layer.masksToBounds = true
        return handle
    }()

    private lazy var closeButton: UIButton = {
        let btn: UIButton = .createIconButton(icon: "xmark", weight: .semibold)
        btn.addAction(for: .touchUpInside) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        return btn
    }()

    private var customView: UIView

    // MARK: - Private Properties
    private let customHeight = UIScreen.main.bounds.height * 0.75
    private var isPresenting = false
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint? // starting point for the animation
    private let treshold: CGFloat = 500
    private let presentingVcMinScale: CGFloat = 0.9

    private var sheetState: SheetState = .shouldOpen {
        didSet {
            sheetStateChanged()
        }
    }

    // MARK: - LifeCycle
    init(customView: UIView) {
        self.customView = customView
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit BottomSheetViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewDidLayoutSubviews() {
        handle.roundCorners(.allCorners, radius: 10)

        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = modalContainerView.frame.origin
        }
        presentingViewController?.view.roundCorners([.topLeft, .topRight], radius: 10)
        modalContainerView.roundCorners([.topLeft, .topRight], radius: 5)
    }

    // MARK: - setup
    private func setup() {
        // self
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(modalContainerView)

        // containerView
        modalContainerView.addSubview(handle)
        modalContainerView.addSubview(closeButton)
        modalContainerView.addSubview(customView)

        modalContainerView.heightAnchor.constraint(equalToConstant: customHeight).isActive = true
        modalContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        modalContainerView.pinSides(to: view)

        // handle
        handle.widthAnchor.constraint(equalToConstant: 40).isActive = true
        handle.heightAnchor.constraint(equalToConstant: 4).isActive = true
        handle.topAnchor.constraint(equalTo: modalContainerView.topAnchor, constant: 8).isActive = true
        handle.centerXAnchor.constraint(equalTo: modalContainerView.centerXAnchor).isActive = true

        // closeButton
        closeButton.heightAnchor.constraint(equalToConstant: 17).isActive = true
        closeButton.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 20).isActive = true
        closeButton.leftAnchor.constraint(equalTo: modalContainerView.leftAnchor, constant: 20).isActive = true

        // customView
        customView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20).isActive = true
        customView.pinSides(to: modalContainerView, padding: 20)
        customView.bottomAnchor.constraint(equalTo: modalContainerView.bottomAnchor, constant: -20).isActive = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        backdropView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        modalContainerView.addGestureRecognizer(panGesture)
    }

    // MARK: - Private Actions
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handleGestureChanged(with: gesture)

        } else if gesture.state == .ended {
            handleGestureEnded(with: gesture)
        }
    }

    @objc private func handleTap(_: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    private func handleGestureChanged(with gesture: UIPanGestureRecognizer) {
        var y = gesture.translation(in: modalContainerView).y
        y = min(customHeight, y) // can not be bigger than the height itself
        y = max(0, y) // can not be smaller than zero

        modalContainerView.frame.origin = CGPoint(x: 0, y: pointOrigin!.y + y)

        let percentage: CGFloat = gesture.translation(in: modalContainerView).y / customHeight
        backdropView.alpha = 1 - percentage

        // to get the same sheet animation for the presenting vc, which makes the presenter scale down
        if let presentingViewController {
            let scale = ((1 - presentingVcMinScale) * percentage) + presentingVcMinScale
            presentingViewController.view.transform = .init(scaleX: scale, y: scale)
        }
    }

    private func handleGestureEnded(with gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: modalContainerView)
        let translation = gesture.translation(in: modalContainerView)

        // check for fast swipe either way
        if abs(velocity.y) > treshold {
            if velocity.y < 0 {
                sheetState = .shouldOpen
            } else {
                sheetState = .shouldClose
            }
            return
        }

        // otherwise (no fast swipe) just use the 'default' condition of above half swipe
        sheetState = translation.y < customHeight / 2 ? .shouldOpen : .shouldClose
    }

    private func sheetStateChanged() {
        switch sheetState {
        case .shouldOpen:
            UIView.animate(withDuration: 0.3) {
                self.modalContainerView.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                self.backdropView.alpha = 1
                self.presentingViewController?.view.transform = .init(scaleX: self.presentingVcMinScale, y: self.presentingVcMinScale)
            }
        case .shouldClose:
            dismiss(animated: true)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
// MARK: UIViewControllerAnimatedTransitioning
extension BottomSheetViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(
        forPresented _: UIViewController,
        presenting _: UIViewController,
        source _: UIViewController
    )
        -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // where your animtaion will take place
        let containerView = transitionContext.containerView
        // the new viewController
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            // indicate that a the transition failed
            transitionContext.completeTransition(false)
            return
        }

        isPresenting.toggle()

        if isPresenting {
            // where our animtaion takes place adds the new viewControllers view as a subview
            containerView.addSubview(toViewController.view)

            modalContainerView.frame.origin.y += customHeight
            backdropView.alpha = 0

            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.modalContainerView.frame.origin.y -= self.customHeight
                self.backdropView.alpha = 1
                self.presentingViewController?.view.transform = .init(scaleX: self.presentingVcMinScale, y: self.presentingVcMinScale)
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.modalContainerView.frame.origin.y += self.customHeight
                self.backdropView.alpha = 0
                self.presentingViewController?.view.transform = .identity
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
}

// MARK: - SheetState
extension BottomSheetViewController {
    private enum SheetState {
        case shouldOpen
        case shouldClose
    }
}
