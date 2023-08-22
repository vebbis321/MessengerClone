//
//  Publishers.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/1/23.
//

import Combine
import Foundation

// MARK: - Custom validation operator
extension Publisher where Self.Output == String, Failure == Never {
    func validateText(validationType: ValidatorType) -> AnyPublisher<ValidationState, Never> {
        let validator = ValidatorFactory.validateForType(type: validationType)
        return validator.validate(publisher: self.eraseToAnyPublisher())
    }
}

// MARK: - Custom string validation operators
extension Publisher where Output == String {
    func isEmpty() -> Publishers.Map<Self, Bool> {
        map { $0.isEmpty }
    }

    func isWithNumbers() -> Publishers.Map<Self, Bool> {
        map { $0.hasNumbers() }
    }

    func isWithSpecialChars() -> Publishers.Map<Self, Bool> {
        map { $0.hasSpecialCharacters() }
    }
}

// MARK: - handleThreads (subscibe to background and receive on main)
extension Publisher {
    func handleThreadsOperator() -> AnyPublisher<Self.Output, Self.Failure> {
        self
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - assign (no retain cycle)
extension Publisher where Failure == Never {
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
}

// MARK: - await
extension Publisher {
    /// Executes an asyncronous call and returns its result to the downstream subscriber.
    ///
    /// - Parameter transform: A closure that takes an element as a parameter and returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream  publisher into a publisher of that element's type.
    func `await`<T>(_ transform: @escaping (Output) async -> T) -> AnyPublisher<T, Failure> {
        flatMap(maxPublishers: .max(1)) { value -> Future<T, Failure> in
            Future { promise in
                Task {
                    let result = await transform(value)
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
