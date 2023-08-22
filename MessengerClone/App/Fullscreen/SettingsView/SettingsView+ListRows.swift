//
//  SettingsView+ListRows.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 7/11/23.
//

import SwiftUI

extension SettingsView {
    // MARK: - ListRows
    enum ListRows: String, CaseIterable {
        case darkMode = "Dark mode"
        case switchAccount = "Sitch account"
        case activeStatus = "Active Status"
        case mobileNumber = "Mobile number"
        case privacyAndSafety = "Privacy and safety"

        var icon: String {
            switch self {
            case .darkMode:
                return "moon.fill"
            case .switchAccount:
                return "repeat.1"
            case .activeStatus:
                return "person.fill"
            case .mobileNumber:
                return "phone.fill"
            case .privacyAndSafety:
                return "lock.fill"
            }
        }

        var foregroundColor: Color {
            return .white
        }

        var backgroundColor: Color {
            switch self {
            case .darkMode:
                return .black
            case .switchAccount:
                return .purple
            case .activeStatus:
                return .green
            case .mobileNumber:
                return .green
            case .privacyAndSafety:
                return .blue
            }
        }
    }
}
