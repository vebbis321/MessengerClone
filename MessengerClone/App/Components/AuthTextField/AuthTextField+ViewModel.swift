//
//  AuthTextField2+ViewModel.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 7/15/23.
//

import UIKit

extension AuthTextField {
    struct ViewModel {
        // MARK: - Constants
        let eyeIcon = "custom-eye"
        let eyeSlashIcon = "custom-eye.slash"
        let xmarkIcon = "custom-xmark"
        let warningIcon = "custom-exclamationmark.circle"

        // MARK: - Properties
        var type: TextFieldType
        var placeholderOption: PlaceholderOption
        var returnKey: UIReturnKeyType

        // MARK: - Init
        init(
            type: TextFieldType,
            placeholderOption: PlaceholderOption = .default,
            returnKey: UIReturnKeyType = .default
        ) {
            self.type = type
            self.placeholderOption = placeholderOption
            self.returnKey = returnKey
        }

        // MARK: - Computed Properties
        // Colors

        var tintColor: UIColor {
            type != .date ? .theme.tintColor! : .clear
        }

        var floatingLabelColor: UIColor {
            type == .date ? .theme.floatingLabel! : .theme.placeholder!
        }

        // Password
        var isSecure: Bool {
            type == .password ? true : false
        }

        // Text
        var placeholder: String? {
            guard type != .date else { return nil }
            switch placeholderOption {
            case .default:
                return type.defaultPlaceholder()
            case let .custom(text):
                return text
            case .empty:
                return ""
            }
        }

        var autocapitalization: UITextAutocapitalizationType {
            type == .name ? .words : .none
        }

        var textContentTypes: UITextContentType? {
            switch type {
            case .name:
                return .name
            case .password:
                return .password
            case .email:
                return .emailAddress
            case .date:
                return .none
            }
        }

        var keyboard: UIKeyboardType {
            type == .email ? .emailAddress : .default
        }

        // RightView
        var rightViewButtonName: String? {
            switch type {
            case .email, .name:
                return xmarkIcon
            case .password:
                return eyeSlashIcon
            case .date:
                return nil
            }
        }

        // MARK: - Methods
        func getCurrentImage(
            focusState: FocusState,
            textState: TextState,
            validationState: ValidationState,
            isPasswordShown: Bool?
        )
            -> UIImage? {
            if type == .password, isPasswordShown != nil {
                // password is a special case
                switch (focusState, textState, validationState) {
                case (.focused, _, _):
                    let name = isPasswordShown! ? eyeSlashIcon : eyeIcon
                    return UIImage(named: name)?.withTintColor(.label)

                case (.inActive, _, .error):
                    return UIImage(named: warningIcon)?.withTintColor(.red)

                default:
                    return nil
                }

            } else {
                // all other cases
                switch (textState, validationState) {
                case (.empty, .error):
                    return UIImage(named: warningIcon)?.withTintColor(.red)

                case (.text, _):
                    return UIImage(named: xmarkIcon)?.withTintColor(.label)

                case (.empty, _):
                    return nil
                }
            }
        }

        func getBorderColor(
            focusState: FocusState,
            validationState: ValidationState
        )
            -> CGColor {
            if case .error = validationState {
                return UIColor.red.cgColor
            } else {
                let color: UIColor? = focusState == .focused ? .theme.activeBorder : .theme.border
                return color!.cgColor
            }
        }

        func getFloatingLabelColor(
            focusState: FocusState,
            textState: TextState,
            validationState: ValidationState
        )
            -> UIColor {
            if case .error = validationState {
                if textState == .text || focusState == .focused {
                    return .red.withAlphaComponent(0.7)
                } else {
                    return .red
                }
            } else {
                if textState == .text || focusState == .focused {
                    return .theme.floatingLabel!
                } else {
                    return .theme.placeholder!
                }
            }
        }
    }
}
