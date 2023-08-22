//
//  MessageBarView.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/26/23.
//

import UIKit

protocol MessageBarTextFieldDelegate: AnyObject {
    func textViewDidBeginEditing(_ textField: MessageBarView)
    func textViewDidEndEditing(_ textField: MessageBarView)
    func textViewShouldReturn(_ textField: MessageBarView) -> Bool
    func textViewDidChange(_ textField: MessageBarView)
}

protocol MessageBarSendable: AnyObject {
    func sendMessage(text: String)
}

protocol MessageBarBtnsDelegate: AnyObject {
    func assetBtnTapped()
}

extension MessageBarTextFieldDelegate {
    func textViewDidBeginEditing(_: MessageBarView) {}
    func textViewDidEndEditing(_: MessageBarView) {}
    func textViewShouldReturn(_: MessageBarView) -> Bool {
        return false
    }
    func textViewDidChange(_: MessageBarView) {}
    func sendMessage(text _: String) {}
}

final class MessageBarView: UIStackView {

    // MARK: - Components
    private lazy var addBtn: UIButton = .createIconButton(icon: "plus.circle.fill", size: 20, color: .theme.button)
    private lazy var cameraBtn: UIButton = .createIconButton(icon: "camera.fill", size: 20, color: .theme.button)
    private lazy var photosBtn: UIButton = .createIconButton(icon: "photo.fill", size: 20, color: .theme.button)
    private lazy var voiceBtn: UIButton = .createIconButton(icon: "mic.fill", size: 20, color: .theme.button)
    private lazy var sendBtn: UIButton = .createIconButton(icon: "hand.thumbsup.fill", size: 20, color: .theme.button)
    private lazy var chevronBtn: UIButton = .createIconButton(icon: "chevron.right", size: 20, color: .theme.button)

    private lazy var leftForTextBtns: [UIButton] = {
        return [addBtn, cameraBtn, photosBtn, voiceBtn]
    }()

    private lazy var textBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .theme.recipientMsgBubble
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.textColor = .label
        textView.font = .systemFont(ofSize: 15, weight: .regular)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0.0
        textView.backgroundColor = .theme.recipientMsgBubble
        textView.keyboardType = .default
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Aa"
        label.sizeToFit()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.isHidden = !textView.text.isEmpty
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Internal properties
    weak var textFieldDelegate: MessageBarTextFieldDelegate?
    weak var sendAble: MessageBarSendable?
    weak var messageBarBtnsDelegate: MessageBarBtnsDelegate?

    // MARK: - Private properties
    private var textViewHeightConstraint: NSLayoutConstraint!
    private var heightFor5Lines: CGFloat = 0.0
    private var numberOfLines: Int {
        return Int(textView.contentSize.height / (textView.font?.lineHeight)!)
    }

    private var viewModel = ViewModel() {
        didSet {
            guard oldValue.viewState != viewModel.viewState else { return }
            handleTextStateChanged()
        }
    }

    // MARK: - LifeCycle
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable) required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setup
    private func setup() {
        backgroundColor = .systemBackground
        axis = .horizontal
        alignment = .bottom
        spacing = 12
        layoutMargins = .init(top: 6, left: 12, bottom: 6, right: 12)
        isUserInteractionEnabled = true
        isLayoutMarginsRelativeArrangement = true

        chevronBtn.alpha = 0.0
        chevronBtn.isHidden = true

        textView.delegate = self
        textView.addSubview(placeholderLabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        textBackgroundView.addGestureRecognizer(tap)
        textView.addGestureRecognizer(tap)
        textBackgroundView.addSubview(textView)

        chevronBtn.addTarget(self, action: #selector(showLeftForTxtBtns), for: .touchUpInside)
        photosBtn.addTarget(self, action: #selector(toggleAssetGrid), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

        addArrangedSubview(chevronBtn)
        leftForTextBtns.forEach { addArrangedSubview($0) }
        addArrangedSubview(textBackgroundView)
        addArrangedSubview(sendBtn)

        // textViewPadding
        let textViewPadding: CGFloat = 10

        // set the width of the textView, but don't change height before it expands by text
        textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: placeholderLabel.intrinsicContentSize.height)
        textViewHeightConstraint.isActive = true

        // pin the placeholderLabel to the textView
        placeholderLabel.pin(to: textView)

        // placeholderLabel now has the correct height for content inside the messageBar
        // use it to correctly allign icons by assigning their height to the same height
        let iconHeight: CGFloat = placeholderLabel.intrinsicContentSize.height + textViewPadding * 2

        // pin the background of the text outside the text (contradicts classic constraints)
        textBackgroundView.topAnchor.constraint(equalTo: textView.topAnchor, constant: -textViewPadding).isActive = true
        textBackgroundView.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: -textViewPadding).isActive = true
        textBackgroundView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: textViewPadding).isActive = true
        textBackgroundView.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: textViewPadding).isActive = true

        chevronBtn.widthAnchor.constraint(equalToConstant: chevronBtn.intrinsicContentSize.width).isActive = true
        chevronBtn.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true

        leftForTextBtns.forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true
        }

        sendBtn.widthAnchor.constraint(equalToConstant: sendBtn.intrinsicContentSize.width).isActive = true
        sendBtn.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true
    }

    // MARK: - Private actions
    @objc private func showLeftForTxtBtns() {
        viewModel.viewState = .showLeftForTextBtns(placeholderLabel.intrinsicContentSize.height)
    }

    @objc private func toggleAssetGrid() {
        messageBarBtnsDelegate?.assetBtnTapped()
    }

    @objc private func handleTap() {
        if textView.isFirstResponder {
            guard viewModel.hideLeftBarBtns == false else { return }
            viewModel.viewState = .hideLeftForTextBtns(textView.contentSize.height, numberOfLines)
        } else {
            textView.becomeFirstResponder()
        }
    }

    @objc private func sendMessage() {
        // TODO: Add different messages
        guard !textView.text.isEmpty else { return }
        sendAble?.sendMessage(text: textView.text)
        textView.text = ""
        evaluateSendBtn()
    }

    // MARK: - Private methods
    private func evaluateSendBtn() {
        UIView.animate(withDuration: 0.25) {
            self.sendBtn.updateIcon(
                newIcon: self.textView.text.isEmpty ? "hand.thumbsup.fill" : "paperplane.fill",
                newColor: .theme.button,
                newSize: 20
            )
            self.layoutIfNeeded()
        }
    }

    // MARK: - Functionality
    private func handleTextStateChanged() {
        print("🚦 State Changed")
        textViewHeightConstraint.constant = viewModel.getTextViewHeight()
        textView.layoutIfNeeded()

        guard viewModel.hideLeftBarBtns != addBtn.isHidden else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.leftForTextBtns.forEach { btn in
                btn.isHidden = self.viewModel.hideLeftBarBtns
                btn.alpha = self.viewModel.leftForTxtBtnsAlpha
            }
            self.chevronBtn.isHidden = !self.viewModel.hideLeftBarBtns
            self.chevronBtn.alpha = self.viewModel.chevronAlpha
            self.layoutIfNeeded()
        }, completion: { _ in
            guard self.viewModel.scrollToBottom == true else { return }
            self.textView.scrollToBottom()
        })
    }
}

// MARK: - UITextViewDelegate
extension MessageBarView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        evaluateSendBtn()
        textFieldDelegate?.textViewDidChange(self)
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewModel.viewState = .textIsActive(textView.contentSize.height, numberOfLines)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textFieldDelegate?.textViewDidBeginEditing(self)
        viewModel.viewState = .textIsActive(textView.contentSize.height, numberOfLines)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textFieldDelegate?.textViewDidEndEditing(self)
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewModel.viewState = .didEndEdit(placeholderLabel.intrinsicContentSize.height)
    }
}

// MARK: - Types
extension MessageBarView {
    typealias Height = CGFloat
    typealias NumberOfLines = Int
}
