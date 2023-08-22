//
//  AuthTextField2+Types.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 7/15/23.
//

import Foundation

extension AuthTextField {
    enum PlaceholderOption {
        case `default`
        case custom(String)
        case empty
    }

    enum TextFieldType: String {
        case name
        case password
        case email
        case date

        func defaultPlaceholder() -> String? {
            return "Enter your \(self.rawValue)..."
        }
    }
}
