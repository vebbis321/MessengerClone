//
//  CustomAlertController.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//

import UIKit

struct AlertButtons {
    var font: UIFont
    var title: String
    var action: () -> Void
}

final class AlertController: UIViewController {
    // MARK: - Private Components
    private lazy var titleLabel: UILabel = {
        let label = PaddingLabel(withInsets: 8, 8, 0, 0)
        label.textColor = .theme.tintColor
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.customize(backgroundColor: .tertiarySystemGroupedBackground, cornerRadius: 12)
        stack.layoutMargins = UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    private var alertButtons: [AlertButtons]

    // MARK: - LifeCycle
    init(alertTitle: String, alertButtons: [AlertButtons]) {
        self.alertButtons = alertButtons
        super.init(nibName: nil, bundle: nil)

        titleLabel.text = alertTitle
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit CustomAlertController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - setup
    private func setup() {
        // self
        view.backgroundColor = .black.withAlphaComponent(0.25)

        // alertBtns
        alertButtons.forEach { btn in
            let uiBtn = UIButton(type: .custom)
            uiBtn.titleLabel?.font = btn.font
            uiBtn.setTitle(btn.title, for: .normal)
            uiBtn.setTitleColor(.theme.alertText, for: .normal)
            uiBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0.01, right: 35)
            uiBtn.addAction(for: .touchUpInside) { _ in
                btn.action()
            }
            uiBtn.translatesAutoresizingMaskIntoConstraints = false

            vStack.addArrangedSubview(uiBtn)
        }

        // seperators
        vStack.addHorizontalSeparators(color: .theme.sepearator ?? .gray)

        view.addSubview(vStack)

        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
