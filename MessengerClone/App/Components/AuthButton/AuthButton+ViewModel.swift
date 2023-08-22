//
//  AuthButton+ViewModel.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/25/23.
//

import UIKit

extension AuthButton {
    struct ViewModel {
        enum ButtonType {
            case `default`
            case secondary
        }

        var buttonType: ButtonType
        var title: String

        init(title: String, buttonType: ButtonType = .default) {
            self.title = title
            self.buttonType = buttonType
        }

        var backgroundColor: UIColor? {
            switch buttonType {
            case .default:
                return .theme.button
            case .secondary:
                return .clear
            }
        }

        var textColor: UIColor? {
            switch buttonType {
            case .default:
                return .theme.buttonText
            case .secondary:
                return .theme.tintColor
            }
        }

        var borderColor: UIColor? {
            switch buttonType {
            case .default:
                return nil
            case .secondary:
                return .theme.border
            }
        }

        var borderWidth: CGFloat {
            switch buttonType {
            case .default:
                return 0
            case .secondary:
                return 1
            }
        }
    }
}
