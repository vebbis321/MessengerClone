//
//  ValidatorFactory.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 7/10/23.
//

import Foundation

// MARK: - Factory
enum ValidatorFactory {
    static func validateForType(type: ValidatorType) -> Validatable {
        switch type {
        case .email:
            return EmailValidator()
        case .phone:
            return PhoneValidator()
        case .password:
            return PasswordValidator()
        case .name:
            return NameValidator()
        }
    }
}
