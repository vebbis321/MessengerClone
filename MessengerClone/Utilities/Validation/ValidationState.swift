//
//  ValidationStates.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 7/10/23.
//

import Foundation

// MARK: - States
enum ValidationState: Equatable {
    case idle
    case error(ErrorState)
    case valid

    enum ErrorState: Equatable {
        case empty
        case invalidEmail
        case invalidPhoneNum
        case toShortPassword
        case passwordNeedsNum
        case passwordNeedsLetters
        case nameCantHaveNumOrSpecialChars
        case toShortName
        case custom(String)

        var description: String {
            switch self {
            case .empty:
                return "Field is empty."
            case .invalidEmail:
                return "Invalid email."
            case .invalidPhoneNum:
                return "Invalid phone number."
            case .toShortPassword:
                return "Your password is to short."
            case .passwordNeedsNum:
                return "Your password doesn't contain any numbers."
            case .passwordNeedsLetters:
                return "Your password doesn't contain any letters."
            case .nameCantHaveNumOrSpecialChars:
                return "Name can't contain numbers or special characters."
            case .toShortName:
                return "Your name can't be less than two characters."
            case let .custom(text):
                return text
            }
        }
    }
}
