////
////  AuthTextField+States.swift
////  Messenger
////
////  Created by Vebjørn Daniloff on 3/9/23.
////
//
// import UIKit
//
// extension AuthTextField {
//    enum ErrorState {
//        case error
//
//        var floatingLabelColor: UIColor? {
//            return .red
//        }
//
//        var borderColor: CGColor? {
//            return UIColor.red.cgColor
//        }
//    }
//
//    enum TextState {
//        case isEmpty
//        case text
//
//        var floatingLabelColor: UIColor? {
//            switch self {
//            case .isEmpty:
//                return .theme.placeholder
//            case .text:
//                return .theme.floatingLabel
//            }
//        }
//
//        var floatingLabelFont: UIFont {
//            switch self {
//            case .isEmpty:
//                return  .systemFont(ofSize: 17, weight: .regular)
//            case .text:
//                return .systemFont(ofSize: 13, weight: .regular)
//            }
//        }
//
//        var textFieldScale: CGAffineTransform {
//            switch self {
//            case .isEmpty:
//                return .identity
//            case .text:
//                return CGAffineTransform(translationX: 0, y: 7.5)
//            }
//        }
//    }
//
//    enum FocusState {
//        case active
//        case inactive
//
//        var borderColor: CGColor? {
//            switch self {
//            case .active:
//                return UIColor.theme.activeBorder?.cgColor
//            case .inactive:
//                return UIColor.theme.border?.cgColor
//            }
//        }
//    }
//
//    enum ButtonState {
//        case isHidden
//        case isShown
//    }
//
// }
