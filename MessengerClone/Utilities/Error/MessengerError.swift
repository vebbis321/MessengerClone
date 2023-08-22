//
//  MessengerError.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import SwiftUI

/// Default error.
enum MessengerError: Error, LocalizedError {
    case `default`(_ error: Error)
    case defaultCustom(_ string: String)
    case someThingWentWrong

    var errorDescription: String? {
        switch self {
        case let .default(err):
            return err.localizedDescription

        case .someThingWentWrong:
            return NSLocalizedString("Something went wrong.", comment: "")

        case let .defaultCustom(customErrorString):
            return NSLocalizedString(customErrorString, comment: "")
        }
    }
}
