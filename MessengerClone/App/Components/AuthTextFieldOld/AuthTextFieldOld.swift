////
////  CustomAuthTextFieldView.swift
////  Messenger
////
////  Created by Vebjørn Daniloff on 3/3/23.
////
//
// import UIKit
// import Combine
//
//
// MARK: - CustomTextField
///// A default type for custom UITextField's. Used to make custom delegate impl protocol simpler for custom UITextField's; When implied, the whole UIView is now "assumed" to be a TextField.
// public protocol CustomTextField: UIView {
//    var textField: UITextField { get set }
// }
//
// MARK: - TextFieldDelegate
// public protocol TextFieldDelegate: AnyObject {
//    func textFieldDidBeginEditing(_ customTextField: CustomTextField)
//    func textFieldDidEndEditing(_ customTextField: CustomTextField)
//    func textFieldShouldReturn(_ customTextField: CustomTextField) -> Bool
//    func textField(_ customTextField: CustomTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
//    func textFieldDidChange(_ customTextField: CustomTextField)
//    func textFieldDidTapMultilineAction(_ customTextField: CustomTextField)
// }
//
// MARK: - TextFieldDelegate default impl
// public extension TextFieldDelegate {
//    func textFieldDidBeginEditing(_ customTextField: CustomTextField) {
//        // Default empty implementation
//    }
//
//    func textFieldDidEndEditing(_ customTextField: CustomTextField) {
//        // Default empty implementation
//    }
//
//    func textFieldShouldReturn(_ customTextField: CustomTextField) -> Bool {
//        return true
//    }
//
//    func textField(_ customTextField: CustomTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return true
//    }
//
//    func textFieldDidChange(_ customTextField: CustomTextField) {
//        // Default empty implementation
//    }
//
//    func textFieldDidTapMultilineAction(_ customTextField: CustomTextField) {
//        // Default empty implementation
//    }
// }
//
//
// class AuthTextField: UIView, CustomTextField {
//
//    // MARK: - Public Components
//    public lazy var textField: UITextField = {
//        let textField = viewModel.type.textFieldType
//        textField.font = .systemFont(ofSize: 17, weight: .regular)
//        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//        textField.delegate = self
//        return textField
//    }()
//
//    // MARK: - Private Components
//    private lazy var floatingLabel: UILabel = {
//        let label = UILabel(frame: .zero)
//        label.font = .systemFont(ofSize: 17, weight: .regular)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private lazy var iconButton: UIButton? = nil
//
//    private lazy var textFieldView: UIView = {
//        let view = UIView(withAutolayout: true)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        view.addGestureRecognizer(tap)
//        view.backgroundColor = .white
//        view.layer.borderWidth = 1
//        view.layer.masksToBounds = true
//        view.layer.cornerRadius = 3
//        view.layer.borderColor = UIColor.theme.border?.cgColor
//        return view
//    }()
//
//    private lazy var hStack: UIStackView = {
//        let stack = UIStackView(frame: .zero)
//        stack.alignment = .leading
//        stack.autoresizingMask = [.flexibleWidth]
//        stack.axis = .horizontal
//        stack.spacing = 10
//        stack.isLayoutMarginsRelativeArrangement = true
//        stack.directionalLayoutMargins = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
//        return stack
//    }()
//
//    lazy var datePicker: UIDatePicker = {
//        let datePicker = UIDatePicker()
//        datePicker.preferredDatePickerStyle = .wheels
//        datePicker.timeZone = .autoupdatingCurrent
//        datePicker.datePickerMode = .date
//        datePicker.maximumDate = Date()
//        datePicker.addTarget(self, action: #selector(handleDateChanged), for: .valueChanged)
//        return datePicker
//    }()
//
//    private lazy var errorLabel: UILabel = {
//        let label = UILabel(frame: .zero)
//        label.numberOfLines = 0
//        label.textAlignment = .left
//        label.textColor = .red
//        label.alpha = 0
//        label.font = .preferredFont(forTextStyle: .footnote)
//        label.isHidden = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private lazy var expandingVstack: UIStackView = {
//        let stack = UIStackView(frame: .zero)
//        stack.axis = .vertical
//        stack.spacing = 10
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//
//    // MARK: - Private Properties
//    private var viewModel: ViewModel
//    private let padding: CGFloat = 15
//
//    // MARK: - Delegate
//    weak var delegate: TextFieldDelegate?
//
//    // MARK: - Combine
//    private var subscriptions = Set<AnyCancellable>()
//    private var validationSubscription: AnyCancellable? = nil
//    public var textFieldSubject = CurrentValueSubject<String, Never>("")
//    public var validationSubject = CurrentValueSubject<ValidationState, Never>(.idle)
//
//    // MARK: - Private State Properties
//    private var errorState: ErrorState? {
//        didSet {
//            print("Error")
//            evaluateErrorState()
//            evaluateButtonState()
//        }
//    }
//
//    private var focusState: FocusState = .inactive {
//        didSet {
//            evaluateTextFocusState()
//            evaluateButtonState()
//        }
//    }
//
//    private var textState: TextState = .isEmpty {
//        didSet {
//            guard viewModel.type != .Date else { return }
//            evaluateIsTextEmptyState()
//            evaluateButtonState()
//        }
//    }
//
//    // MARK: - LifeCycle
//    init(viewModel: ViewModel) {
//        self.viewModel = viewModel
//        super.init(frame: .zero)
//        setup()
//    }
//
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func didMoveToWindow() {
//        // similar to viewWillAppear
//        switch viewModel.type {
//        case .Date:
//            updateDate()
//        default:
//            guard let validatorType = viewModel.type.validatorType else { return }
//            guard validationSubject.value == .idle else { return }
//
//            textField.createBinding(with: textFieldSubject, storeIn: &subscriptions)
//
//            textField.validateText(validationType: validatorType, publisher: textFieldSubject.eraseToAnyPublisher())
//                .assign(to: \.validationSubject.value, on: self)
//                .store(in: &subscriptions)
//        }
//    }
//
//    deinit {
//        print("✅ Deinit AuthTextField")
//    }
//
//
//
//    // MARK: - Public Methods
//    public func startValidation() {
//        guard validationSubscription == nil else { return }
//        validationSubscription = validationSubject
//            .handleThreadsOperator()
//            .sink { [weak self] state in
//                switch state {
//                case .idle:
//                    break
//                case .error(let errType):
//                    self?.showErrorLabel()
//                    self?.errorState = .error
//                    self?.errorLabel.text = errType.description
//                case .valid:
//                    self?.hideErrorLabel()
//                    self?.errorState = nil
//                }
//            }
//    }
//
//    // MARK: - Private Methods
//    private func showErrorLabel() {
//        guard errorLabel.isHidden == true else { return }
//
//        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
//            self.errorLabel.isHidden = false
//            self.layoutIfNeeded()
//        } completion: { _ in
//            self.errorLabel.alpha = 1
//        }
//
//    }
//
//    private func hideErrorLabel() {
//        guard errorLabel.isHidden == false else { return }
//        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
//            self.errorLabel.alpha = 0
//            self.errorLabel.isHidden = true
//            self.layoutIfNeeded()
//        }
//    }
//
//    private func evaluateIsTextEmptyState() {
//        // so we don't set the properties of textField if its already set
//        guard textField.transform != textState.textFieldScale else { return }
//        floatingLabel.transform = textState == .isEmpty ? .identity : .init(translationX: 0, y: -((textField.intrinsicContentSize.height * 0.5) + 5))
//        floatingLabel.font = textState.floatingLabelFont
//        textField.transform = textState.textFieldScale
//        floatingLabel.textColor = textState.floatingLabelColor
//
//        guard errorState != .error else { return }
//        floatingLabel.textColor = textState.floatingLabelColor
//    }
//
//    private func evaluateTextFocusState() {
//        guard errorState != .error else { return }
//        textFieldView.layer.borderColor = focusState.borderColor
//    }
//
//    private func evaluateErrorState() {
//        switch errorState {
//        case .none:
//            floatingLabel.textColor = textState.floatingLabelColor
//            textFieldView.layer.borderColor = focusState.borderColor
//            iconButton?.updateIcon(newIcon: "xmark", newColor: .theme.tintColor)
//
//        case .some(let state):
//            floatingLabel.textColor = state.floatingLabelColor
//            textFieldView.layer.borderColor = state.borderColor
//        }
//
//    }
//
//    private func evaluateButtonState() {
//        guard let rightViewButton = iconButton else { return }
//        switch viewModel.type {
//        case .Default:
//            switch textState {
//            case .isEmpty:
//                if errorState != nil {
//                    rightViewButton.updateIcon(newIcon: "exclamationmark.circle", newColor: .red, newSize: 17)
//
//                    rightViewButton.isHidden = false
//                } else {
//                    rightViewButton.isHidden = true
//                }
//
//            case .text:
//                rightViewButton.isHidden = false
//                guard errorState != nil else { return }
//                rightViewButton.updateIcon(newIcon: "xmark", newColor: .theme.tintColor, newSize: 17)
//            }
//        case .Password:
//            switch focusState {
//            case .active:
//                rightViewButton.isHidden = false
//            case .inactive:
//                rightViewButton.isHidden = true
//            }
//        case .Date: break
//        }
//    }
//
//    // MARK: - Private Actions
//    @objc private func handleTap() {
//        textField.becomeFirstResponder()
//    }
//
//    @objc private func textFieldDidChange(_ textField: UITextField) {
//        textState = textField.hasText ? .text : .isEmpty
//    }
//
//    private func clearBtnTapped() {
//        textField.text = ""
//        textState = .isEmpty
//        // for combine
//        NotificationCenter.default.post(
//            name:UITextField.textDidChangeNotification, object: textField)
//    }
//
//    private func toggleShowHidePasswordBtnTapped() {
//        guard let rightViewButton = iconButton else { return }
//        textField.togglePasswordVisibility()
//        rightViewButton.updateIcon(
//            newIcon: textField.isSecureTextEntry ? "eye.slash" : "eye",
//            newColor: .theme.tintColor ?? .label,
//            newWeight: .regular
//        )
//    }
//
//    @objc private func handleDateChanged() {
//        updateDate()
//    }
//
//    private func updateDate() {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        textField.text = formatter.string(from: datePicker.date)
//        let age = Calendar.current.dateComponents([.year], from: datePicker.date, to: Date())
//        floatingLabel.text = "Date of birth (\(age.year ?? 0) year old)"
//    }
//
//    // MARK: - setup
//    private func setup() {
//        switch viewModel.type {
//        case .Date:
//            textField.inputView = datePicker
//            textField.transform = .init(translationX: 0, y: 7.5)
//            floatingLabel.font = .systemFont(ofSize: 13, weight: .regular)
//            floatingLabel.transform = .init(translationX: 0, y: -((textField.intrinsicContentSize.height * 0.5) + 5))
//        default:
//            break
//        }
//
//
//        // custom
//        textField.keyboardType = viewModel.type.keyboard
//        textField.returnKeyType = viewModel.returnKey
//        textField.textContentType = viewModel.type.textContentTypes
//        textField.autocapitalizationType = viewModel.type.autocapitalization
//
//        floatingLabel.text = viewModel.placeholder
//        floatingLabel.textColor = viewModel.type.floatingLabelColor
//
//        textField.isSecureTextEntry = viewModel.type.isSecure
//        textField.tintColor = viewModel.type.tintColor
//
//        textField.addSubview(floatingLabel)
//        hStack.addArrangedSubview(textField)
//        textFieldView.addSubview(hStack)
//
//        addSubview(expandingVstack)
//
//        expandingVstack.addArrangedSubview(textFieldView)
//        expandingVstack.addArrangedSubview(errorLabel)
//
//        // hStack
//        hStack.pin(to: textFieldView)
//
//        // textFieldView
//        textFieldView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//
//        // floatingLabel
//        floatingLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
//
//        // errorLabel
//        errorLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//
//        // Container stack view
//        expandingVstack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        expandingVstack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//
//        translatesAutoresizingMaskIntoConstraints = false
//        widthAnchor.constraint(equalTo: expandingVstack.widthAnchor).isActive = true
//        heightAnchor.constraint(equalTo: expandingVstack.heightAnchor).isActive = true
//
//        // Add rightView if rightView is not nil
//        guard let iconBtnConf = viewModel.type.iconButton else { return }
//        iconButton = .createIconButton(
//              icon: iconBtnConf.icon
//        )
//        guard let iconBtn = iconButton else { return }
//        iconBtn.isHidden = true
//        iconBtn.addAction(for: .touchUpInside) { [weak self] _ in
//            guard let self = self else { return }
//            switch self.viewModel.type {
//            case .Default:
//                self.clearBtnTapped()
//            case .Password:
//                self.toggleShowHidePasswordBtnTapped()
//            default: break
//            }
//        }
//
//        hStack.addArrangedSubview(iconBtn)
//        layoutIfNeeded()
//    }
// }
//
// MARK: - UITextFieldDelegate
// extension AuthTextField: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        delegate?.textFieldDidBeginEditing(self)
//        focusState = .active
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        focusState = .inactive
//    }
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        guard viewModel.type == .Date else { return true }
//        if textField.tag == 1 {
//            textField.text = ""
//            return false
//        }
//        return true
//    }
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard viewModel.type == .Date else { return true }
//        if textField.tag == 1 {
//            textField.text = ""
//            return false
//        }
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return delegate?.textFieldShouldReturn(self) ?? true
//    }
// }
//
//
// MARK: - Test VC
// final class TextfieldVC: UIViewController {
//    let txtField = AuthTextField(
//        viewModel: .init(
//            placeholder: "Clear",
//            returnKey: .default, type: .Default(.Email)))
//    let txtField2 = AuthTextField(
//        viewModel: .init(
//            placeholder: "Password",
//            returnKey: .default, type: .Password))
//    let txtField3 = AuthTextField(
//        viewModel: .init(
//            placeholder: "Date",
//            returnKey: .default, type: .Date))
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        hideKeyboardWhenTappedAround()
//        view.backgroundColor = .theme.background
//
//        view.addSubview(txtField)
//        view.addSubview(txtField2)
//        view.addSubview(txtField3)
//
//        txtField.translatesAutoresizingMaskIntoConstraints = false
//        txtField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        txtField.pinSides(to: view, padding: 20)
//
//        txtField2.translatesAutoresizingMaskIntoConstraints = false
//        txtField2.topAnchor.constraint(equalTo: txtField.bottomAnchor, constant: 10).isActive = true
//        txtField2.pinSides(to: view, padding: 20)
//
//        txtField3.translatesAutoresizingMaskIntoConstraints = false
//        txtField3.topAnchor.constraint(equalTo: txtField2.bottomAnchor, constant: 10).isActive = true
//        txtField3.pinSides(to: view, padding: 20)
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
////        txtField.errorState = .error
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            self.txtField.startValidation()
//        }
//    }
// }
//
//
//
//
// import SwiftUI
//
// struct TxtFieldVCPreview: PreviewProvider {
//    static var previews: some View {
//        UIViewControllerPreview {
//            TextfieldVC()
//        }
//        .previewDevice("iPhone 12 mini")
//    }
// }
//
//
