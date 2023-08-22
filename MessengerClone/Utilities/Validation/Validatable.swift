//
//  CustomValidation.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/10/23.
//

import Combine
import UIKit

// MARK: - Validatable
protocol Validatable {
    func validate(publisher: AnyPublisher<String, Never>) -> AnyPublisher<ValidationState, Never>
}

// MARK: - Validation Publishers
extension Validatable {
    func isEmpty(with publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .isEmpty()
            .eraseToAnyPublisher()
    }

    func isToShort(with publisher: AnyPublisher<String, Never>, count: Int) -> AnyPublisher<Bool, Never> {
        publisher
            .map { !($0.count >= count) }
            .eraseToAnyPublisher()
    }

    func hasNumbers(with publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .isWithNumbers()
            .eraseToAnyPublisher()
    }

    func hasLetters(with publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.contains(where: { $0.isLetter }) }
            .eraseToAnyPublisher()
    }

    func hasSpecialChars(with publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .isWithSpecialChars()
            .eraseToAnyPublisher()
    }

    func isEmail(with publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.isValidEmail() }
            .eraseToAnyPublisher()
    }

    func isPhoneNumber(with publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.isPhoneNumValid() }
            .eraseToAnyPublisher()
    }
}

// MARK: - Custom Validations
struct EmailValidator: Validatable {
    func validate(
        publisher: AnyPublisher<String, Never>
    ) -> AnyPublisher<ValidationState, Never> {
        Publishers.CombineLatest(
            isEmpty(with: publisher),
            isEmail(with: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map { isEmpty, isEmail in
            if isEmpty { return .error(.empty) }
            if !isEmail { return .error(.invalidEmail) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}

struct PhoneValidator: Validatable {
    func validate(
        publisher: AnyPublisher<String, Never>
    ) -> AnyPublisher<ValidationState, Never> {
        Publishers.CombineLatest(
            isEmpty(with: publisher),
            isPhoneNumber(with: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map { isEmpty, isPhoneNum in
            if isEmpty { return .error(.empty) }
            if !isPhoneNum { return .error(.invalidPhoneNum) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}

struct PasswordValidator: Validatable {
    func validate(
        publisher: AnyPublisher<String, Never>
    ) -> AnyPublisher<ValidationState, Never> {
        Publishers.CombineLatest4(
            isEmpty(with: publisher),
            isToShort(with: publisher, count: 6),
            hasNumbers(with: publisher),
            hasLetters(with: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map { isEmpty, toShort, hasNumbers, hasLetters in
            if isEmpty { return .error(.empty) }
            if toShort { return .error(.toShortPassword) }
            if !hasNumbers { return .error(.passwordNeedsNum) }
            if !hasLetters { return .error(.passwordNeedsLetters) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}

struct NameValidator: Validatable {
    func validate(
        publisher: AnyPublisher<String, Never>
    ) -> AnyPublisher<ValidationState, Never> {
        Publishers.CombineLatest4(
            isEmpty(with: publisher),
            isToShort(with: publisher, count: 2),
            hasNumbers(with: publisher),
            hasSpecialChars(with: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map { isEmpty, toShort, hasNumbers, hasSpecialChars in
            if isEmpty { return .error(.empty) }
            if toShort { return .error(.toShortName) }
            if hasNumbers || hasSpecialChars { return .error(.nameCantHaveNumOrSpecialChars) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}
