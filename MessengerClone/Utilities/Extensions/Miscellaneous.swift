//
//  Miscala.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/22/23.
//

import UIKit

// MARK: - addAction
extension UIControl {
    func addAction(for event: UIControl.Event, handler: @escaping UIActionHandler) {
        addAction(UIAction(handler: handler), for: event)
    }
}

// From SwiftBySundell
// MARK: - concurrentForEach
extension Sequence {
    func concurrentForEach(
        _ operation: @escaping (Element) async throws -> Void
    )
        async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    guard let value = try? await operation(element) else {
                        return
                    }
                    return value
                }
            }
        }
    }
}
