//
//  Date.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import Foundation

// MARK: - unix timestamp
typealias UnixTimestamp = Int

extension Date {
    /// Date to Unix timestamp.
    var unixTimestamp: UnixTimestamp {
        return UnixTimestamp(self.timeIntervalSince1970 * 1000) // millisecond precision
    }
}

extension UnixTimestamp {
    /// Unix timestamp to date.
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(self / 1000)) // must take a millisecond-precise Unix timestamp
    }
}

// MARK: - formatRelativeString
extension Date {
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday - 1]
        } else {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .medium
        }

        return dateFormatter.string(from: self).uppercased()
    }
}

// MARK: - localizedDescription
extension Date {
    var localizedDescription: String {
        return description(with: .current)
    }
}
