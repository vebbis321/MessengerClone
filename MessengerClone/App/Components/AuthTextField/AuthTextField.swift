//
//  AuthTextField2.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 7/13/23.
//

import Combine
import SwiftUI

// MARK: - TextFieldDelegate
protocol AuthTextFieldDelegate: AnyObject {
    func textFieldDidBeginEditing(_ customTextField: AuthTextField)
    func textFieldDidEndEditing(_ customTextField: AuthTextField)
    func textFieldShouldReturn(_ customTextField: AuthTextField) -> Bool
    func textField(_ customTextField: AuthTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldDidChange(_ customTextField: AuthTextField)
    func textFieldDidTapMultilineAction(_ customTextField: AuthTextField)
}

extension AuthTextFieldDelegate {
    func textFieldDidBeginEditing(_: AuthTextField) {
        // Default empty implementation
    }

    func textFieldDidEndEditing(_: AuthTextField) {
        // Default empty implementation
    }

    func textFieldShouldReturn(_: AuthTextField) -> Bool {
        return true
    }

    func textField(_: AuthTextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        return true
    }

    func textFieldDidChange(_: AuthTextField) {
        // Default empty implementation
    }

    func textFieldDidTapMultilineAction(_: AuthTextField) {
        // Default empty implementation
    }
}

final class AuthTextField: UIView {
    // MARK: - Components
    lazy var textField: UITextField = {
        let textField = viewModel.type == .date ? DisabledTextField(withAutolayout: true) : UITextField(withAutolayout: true)
        textField.textColor = .label
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.invalidateIntrinsicContentSize()
        return textField
    }()

    private lazy var floatingLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private lazy var textFieldbackgroundView: UIView = {
        let view = UIView(withAutolayout: true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor.theme.border?.cgColor
        return view
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(handleDateChanged), for: .valueChanged)
        return datePicker
    }()

    private lazy var iconButton: UIButton? = nil

    private lazy var errorLabel: UILabel = {
        let label = UILabel(withAutolayout: true)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .red
        //        label.alpha = 1
        label.font = .preferredFont(forTextStyle: .footnote)
        label.isHidden = true
        return label
    }()

    private lazy var expandingVstack: UIStackView = {
        let stack = UIStackView(withAutolayout: true)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }()

    // MARK: - Properties
    // because why not
    private let textFieldHeight = getWindowHeight() * 0.03
    private var viewModel: ViewModel
    weak var delegate: AuthTextFieldDelegate?

    @Published private var focusState: FocusState = .inActive
    @Published private var textState: TextState = .empty
    @Published private var validationState: ValidationState = .idle

    private var canShowFeedBack = false

    private var statePublisher: AnyPublisher<(FocusState, TextState, ValidationState), Never> {
        return Publishers.CombineLatest3($focusState, $textState, $validationState)
            .removeDuplicates { prev, curr in
                prev == curr
            }.eraseToAnyPublisher()
    }

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - LifeCycle
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
        observeValidationState()
        observeStates()
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("✅ Deinit AuthTextField")
    }

    // MARK: - setup
    private func setup() {
        textField.keyboardType = viewModel.keyboard
        textField.returnKeyType = viewModel.returnKey
        textField.textContentType = viewModel.textContentTypes
        textField.autocapitalizationType = viewModel.autocapitalization
        textField.tintColor = viewModel.tintColor
        textField.isSecureTextEntry = viewModel.isSecure

        floatingLabel.text = viewModel.placeholder
        floatingLabel.textColor = viewModel.floatingLabelColor

        if viewModel.type == .date {
            textField.inputView = datePicker
            handleDateChanged()
            textState = .text
        }

        textField.anchor(heightConstant: textFieldHeight)

        addSubview(expandingVstack)

        expandingVstack.addArrangedSubview(textFieldbackgroundView)
        expandingVstack.addArrangedSubview(errorLabel)

        hStack.addArrangedSubview(textField)

        textFieldbackgroundView.addSubview(hStack)
        textField.addSubview(floatingLabel)

        textFieldbackgroundView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

        hStack.anchor(
            top: textFieldbackgroundView.topAnchor, paddingTop: 20,
            bottom: textFieldbackgroundView.bottomAnchor, paddingBottom: 20,
            left: textFieldbackgroundView.leftAnchor, paddingLeft: 20,
            right: textFieldbackgroundView.rightAnchor, paddingRight: 20
        )

        floatingLabel.anchor(centerY: textField.centerYAnchor)
        errorLabel.anchor(width: widthAnchor)

        translatesAutoresizingMaskIntoConstraints = false
        anchor(height: expandingVstack.heightAnchor)

        // Add rightView if rightView is not nil
        if let rightViewBtnName = viewModel.rightViewButtonName {
            iconButton = .createCustomIconImage(customIcon: rightViewBtnName, size: textFieldHeight * 0.9)

            guard let iconBtn = iconButton else { return }

            iconBtn.isHidden = true
            iconBtn.addAction(for: .touchUpInside) { [weak self] _ in
                guard let self else { return }
                switch self.viewModel.type {
                case .email, .name:
                    self.clearBtnTapped()
                case .password:
                    self.toggleShowHidePasswordBtnTapped()
                default: break
                }
            }

            hStack.addArrangedSubview(iconBtn)
            layoutIfNeeded()
        }
    }

    // MARK: - Observe
    private func observeStates() {
        statePublisher
            .sink { [weak self] focus, text, validation in
                guard let self else { return }
                let val = self.canShowFeedBack == true ? validation : .idle
                self.stateChanged(focusState: focus, textState: text, validationState: val)
            }.store(in: &subscriptions)
    }

    private func observeValidationState() {
        guard validationState == .idle, let validationType = ValidatorType(rawValue: viewModel.type.rawValue) else { return }

        textField.textPublisher()
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .validateText(validationType: validationType)
            .assign(to: &$validationState)

        // if text is empty
        NotificationCenter.default.post(
            name: UITextField.textDidChangeNotification, object: textField
        )
    }

    // MARK: - Functionality
    private func stateChanged(
        focusState: FocusState,
        textState: TextState,
        validationState: ValidationState
    ) {
        textFieldbackgroundView.layer.borderColor = viewModel.getBorderColor(
            focusState: focusState,
            validationState: validationState
        )
        floatingLabel.textColor = viewModel.getFloatingLabelColor(
            focusState: focusState,
            textState: textState,
            validationState: validationState
        )
        animateFloatingLabel(focuseState: focusState, textState: textState)
        animateErrorLabel(validationState: validationState)

        guard viewModel.type != .date else { return }

        if let img = viewModel.getCurrentImage(
            focusState: focusState,
            textState: textState,
            validationState: validationState,
            isPasswordShown: textField.isSecureTextEntry
        ) {
            iconButton?.isHidden = false
            iconButton?.setImage(img, for: .normal)
        } else {
            iconButton?.isHidden = true
        }

        hStack.layoutIfNeeded()
    }

    // MARK: - Internal method
    @discardableResult
    func isValidText() -> String? {
        if let text = textField.text,
            validationState == .valid {
            return text
        } else {
            showFeedBack()
            return nil
        }
    }

    private func showFeedBack() {
        guard canShowFeedBack != true else { return }
        canShowFeedBack = true
        stateChanged(focusState: focusState, textState: textState, validationState: validationState)
    }

    // MARK: - Private actions / methods
    @objc private func handleDateChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        textField.text = formatter.string(from: datePicker.date)

        let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date())
        floatingLabel.text = "Date of birth (\(age.year ?? 0) year old)"
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        textState = textField.hasText ? .text : .empty
    }

    @objc private func handleTap() {
        textField.becomeFirstResponder()
    }

    private func toggleShowHidePasswordBtnTapped() {
        guard let rightViewButton = iconButton else { return }
        textField.togglePasswordVisibility()
        let prefix = "custom-"
        let end = textField.isSecureTextEntry ? "eye.slash" : "eye"

        if let image = UIImage(named: prefix + end) {
            rightViewButton.setImage(image, for: .normal)
        }
    }

    private func clearBtnTapped() {
        textField.text = ""
        textState = .empty
        focusState = .inActive

        // for combine
        NotificationCenter.default.post(
            name: UITextField.textDidChangeNotification, object: textField
        )
    }

    private func animateFloatingLabel(
        focuseState: FocusState,
        textState: TextState
    ) {
        var floatingTransform: CGAffineTransform!
        var textFieldTransform: CGAffineTransform!
        var floatingLabelFont: UIFont!
        let padding: CGFloat = 5

        if focuseState == .focused {
            guard floatingLabel.transform == .identity else { return }
            floatingLabelFont = .systemFont(ofSize: 13, weight: .regular)
            floatingTransform = .init(translationX: 0, y: -((textFieldHeight * 0.5) + padding))
            textFieldTransform = .init(translationX: 0, y: 7.5)
        } else {
            switch textState {
            case .empty:
                guard floatingLabel.transform != .identity else { return }
                floatingLabelFont = .systemFont(ofSize: 17, weight: .regular)
                floatingTransform = .identity
                textFieldTransform = .identity

            case .text:
                guard floatingLabel.transform == .identity else { return }
                floatingLabelFont = .systemFont(ofSize: 13, weight: .regular)
                floatingTransform = .init(translationX: 0, y: -((textFieldHeight * 0.5) + padding))
                textFieldTransform = .init(translationX: 0, y: 7.5)
            }
        }

        UIView.animate(withDuration: 0.1) {
            self.floatingLabel.transform = floatingTransform
            self.textField.transform = textFieldTransform
            self.floatingLabel.font = floatingLabelFont
            self.layoutIfNeeded()
        }
    }

    private func animateErrorLabel(validationState: ValidationState) {
        UIView.animate(withDuration: 0.25) {
            if case let .error(errorState) = validationState {
                self.errorLabel.text = errorState.description
                guard self.errorLabel.isHidden == true else { return } // stack acts wierd if you set the same hide/show state
                self.errorLabel.isHidden = false

            } else if case .valid = validationState {
                self.errorLabel.text = nil
                guard self.errorLabel.isHidden == false else { return }
                self.errorLabel.isHidden = true
            }
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate
extension AuthTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        delegate?.textFieldDidBeginEditing(self)
        focusState = .focused
    }

    func textFieldDidEndEditing(_: UITextField) {
        delegate?.textFieldDidEndEditing(self)
        focusState = .inActive
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        delegate?.textFieldShouldReturn(self) ?? true
    }
}

// MARK: - Test VC
final class TextfieldVC2: UIViewController {
    let txtField = AuthTextField(
        viewModel: .init(
            type: .name,
            placeholderOption: .custom("Surname"),
            returnKey: .default
        )
    )

    let txtField2 = AuthTextField(
        viewModel: .init(
            type: .password,
            returnKey: .default
        )
    )

    let txtField3 = AuthTextField(
        viewModel: .init(
            type: .date,
            returnKey: .default
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .theme.background

        view.addSubview(txtField)
        view.addSubview(txtField2)
        view.addSubview(txtField3)

        txtField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        txtField.pinSides(to: view, padding: 20)

        txtField2.topAnchor.constraint(equalTo: txtField.bottomAnchor, constant: 10).isActive = true
        txtField2.pinSides(to: view, padding: 20)

        txtField3.topAnchor.constraint(equalTo: txtField2.bottomAnchor, constant: 10).isActive = true
        txtField3.pinSides(to: view, padding: 20)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.txtField.isValidText()
        }
    }
}

struct TxtFieldVCPreview2: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            TextfieldVC2()
        }
        .previewDevice("iPhone 12 mini")
    }
}
