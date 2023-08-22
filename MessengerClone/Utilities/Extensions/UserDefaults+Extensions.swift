//
//  UserDefaults+Extensions.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 7/10/23.
//

import Combine
import Foundation

// MARK: - Keys
extension UserDefaults {
    private enum Keys {
        static let keyboardHeight = "keyboardHeight"
    }
}

// MARK: - keyboardHeight
extension UserDefaults {
    var keyboardHeight: Float? {
        get {
            float(forKey: Keys.keyboardHeight)
        }
        set {
            set(newValue, forKey: Keys.keyboardHeight)
        }
    }
}
