//
//  LaunchVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/1/23.
//

import Combine
import SwiftUI

final class LaunchViewController: UIViewController {
    // MARK: - Properties
    private lazy var fakeTextField = UITextField(withAutolayout: true)
    private var cancellable: AnyCancellable?
    var countDown: Double = 3.0

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        observeKeyboard()
        setup()
        startCountDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fakeTextField.becomeFirstResponder()
        fakeTextField.removeFromSuperview()
    }

    // MARK: - Setup
    private func setup() {
        // add fakteTextField
        view.addSubview(fakeTextField)
        fakeTextField.anchor(heightConstant: 50, widthConstant: 200, centerX: view.centerXAnchor, centerY: view.centerYAnchor)

        // setup the SwiftUI view as our content view for this VC
        let childView = UIHostingController(rootView: LaunchView())
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.pin(to: view)
    }

    // MARK: - Private method
    private func startCountDown() {
        cancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                if self?.countDown == 0 {
                    self?.cancellable?.cancel()
                    self?.cancellable = nil
                }
                self?.countDown -= 1
            })
    }

    // MARK: - Observe
    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    // MARK: - Actions
    @objc private func keyboardWillAppear(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UserDefaults.standard.keyboardHeight = Float(keyboardSize.height)
        }
    }

    deinit {
        print("✅ Deinit LaunchViewController")
        NotificationCenter.default.removeObserver(self)
    }
}
