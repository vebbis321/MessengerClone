////
////  AuthTextFieldView+ViewModel.swift
////  Messenger
////
////  Created by Vebjørn Daniloff on 3/9/23.
////
//
// import UIKit
//
// extension AuthTextField {
//    struct ViewModel {
//        // MARK: - TextField types
//        enum TextFieldType: Equatable {
//            var validatorType: ValidatorType? {
//                switch self {
//                case .Default(let defaultType):
//                    switch defaultType {
//                    case .Email:
//                        return .email
//                    case .Phone:
//                        return .phone
//                    case .OTP:
//                        return .none
//                    case .Name:
//                        return .name
//                    case .Default:
//                        return .none
//                    }
//                case .Password:
//                    return .password
//                case .Date:
//                    return nil
//                }
//            }
//
//
//            private var value: String? {
//                return String(describing: self).components(separatedBy: "(").first
//            }
//            static private func == (lhs: TextFieldType, rhs: TextFieldType) -> Bool {
//                lhs.value == rhs.value
//            }
//
//            case Default(DefaultTypes)
//            case Password
//            case Date
//
//            // MARK: - Default child types
//            /// Child types for the default AuthTextField.
//            enum DefaultTypes {
//                case Email
//                case Phone
//                case OTP
//                case Name
//                case Default
//            }
//
//            var textContentTypes: UITextContentType? {
//                switch self {
//                case .Default(let childTypes):
//                    switch childTypes {
//                    case .Email:
//                        return .emailAddress
//                    case .Phone:
//                        return .telephoneNumber
//                    case .OTP:
//                        return .oneTimeCode
//                    case .Name:
//                        return .name
//                    case .Default:
//                        return .none
//                    }
//                case .Password:
//                    return .password
//                case .Date:
//                    return .none
//                }
//            }
//
//            var autocapitalization: UITextAutocapitalizationType {
//                switch self {
//                case .Default(let childTypes):
//                    switch childTypes {
//                    case .Name:
//                        return .words
//                    default:
//                        return .none
//                    }
//                default:
//                    return .none
//                }
//            }
//
//            var keyboard: UIKeyboardType {
//                switch self {
//                case .Default(let childtypes):
//                    switch childtypes {
//                    case .Email:
//                        return .emailAddress
//                    case .Phone:
//                        return .phonePad
//                    case .OTP:
//                        return .numberPad
//                    case .Name:
//                        return .default
//                    case .Default:
//                        return .default
//                    }
//                default:
//                    return .default
//                }
//            }
//
//            var isSecure: Bool {
//                self == .Password ? true : false
//            }
//
//            var textFieldType: UITextField {
//                switch self {
//                case .Date:
//                    return DisabledTextField()
//                default:
//                    return UITextField()
//                }
//            }
//
//            var floatingLabelColor: UIColor? {
//                switch self {
//                case .Date:
//                    return .theme.floatingLabel
//                default:
//                    return .theme.placeholder
//                }
//            }
//
//            var textColor: UIColor? {
//                switch self {
//                case .Date:
//                    return .clear
//                default:
//                    return .label
//                }
//            }
//
//            var tintColor: UIColor {
//                switch self {
//                case .Date:
//                    return .clear
//                default:
//                    return .theme.tintColor ?? .label
//                }
//            }
//
//            var iconButton: IconButton? {
//                switch self {
//                case .Default:
//                    return .init(icon: "xmark", size: 17)
//                case .Password:
//                    return .init(icon: "eye.slash", size: 17)
//                case .Date:
//                    return nil
//                }
//            }
//
//        }
//
//        // MARK: - Button
//        struct IconButton {
//            let icon: String
//            let size: CGFloat
//        }
//
//        let placeholder: String
//        let returnKey: UIReturnKeyType
//        let type: TextFieldType
//    }
// }
