//
//  String.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/1/23.
//

import UIKit

// MARK: - Create chatId one-to-one
extension String {
    /// Use this method to create/get a one to one id for chat. The id will be determined by the size of the userId and the recipientId.
    /// With this approach we will always get the same id in a one to one chat.
    /// - Returns: The combined id
    static func getChatId(userId: String, recipientId: String) -> String {
        return "chat_room_\(userId > recipientId ? userId : recipientId)_\(userId > recipientId ? recipientId : userId)"
    }
}

// MARK: - Factory for Firestore collection path
extension String {
    enum CollectionPath: String {
        case userPublic
        case userPrivate
    }

    // Factory
    static func getPath(for path: CollectionPath) -> String {
        switch path {
        case .userPrivate, .userPublic:
            return path.rawValue
        }
    }
}

extension String {
    static func getPathToUserChats(userId: String) -> String {
        "userChats/\(userId)"
    }

    static func getPathToChatRooms(userId: String, chatRoomId: String) -> String {
        "userChats/\(userId)/\(chatRoomId)"
    }

    static func getPathToChatMessage(chatRoomId: String, messageId: String) -> String {
        "chatMessages/\(chatRoomId)/\(messageId)"
    }

    static func getPathToChatMessages(chatRoomId: String) -> String {
        "chatMessages/\(chatRoomId)"
    }

    static func getPathToLastMessgae(chatRoomid: String) -> String {
        "lastMessage/\(chatRoomid)"
    }

}

// MARK: - Split name to array of 'keywords'
extension String {
    ///  Splits the current text in to an array of suitable strings for searching.
    /// - Parameter maximumStringSize: To prevent the array getting to big. This will be the last splitted character.
    /// - Returns: Array of strings. Where the strings is used for searching.
    func createSubstringArray(maximumStringSize: Int?) -> [String] {
        var substringArray = [String]()
        var characterCounter = 1
        let textLowercased = self.lowercased()

        let characterCount = self.count
        for _ in 0 ... characterCount {
            for x in 0 ... characterCount {
                let lastCharacter = x + characterCounter
                if lastCharacter <= characterCount {
                    let substring = textLowercased[x ..< lastCharacter]
                    substringArray.append(substring)
                }
            }
            characterCounter += 1

            if let max = maximumStringSize, characterCounter > max {
                break
            }
        }

        print(substringArray)
        return substringArray
    }
}

// MARK: - To help the split keyword helperFunction
extension String {
    private var length: Int {
        return count
    }

    private subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }

    private func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    private func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    private subscript(intRange: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (
            lower: max(0, min(length, intRange.lowerBound)),
            upper: min(length, max(0, intRange.upperBound))
        ))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

// MARK: - get coordinates from str
extension StringProtocol {
    func characterPosition(character: Character, with font: UIFont = .systemFont(ofSize: 18.0)) -> CGPoint? {
        guard let index = firstIndex(of: character) else {
            print("\(character) is missed")
            return nil
        }
        let string = String(self[..<index])
        let size = string.size(withAttributes: [.font: font])
        return CGPoint(x: size.width, y: 0)
    }
}

// MARK: - Predicates
extension String {
    func hasUppecaseCharacters() -> Bool {
        return stringFulfillsRegex(regex: ".*[A-Z]+.*")
    }

    func hasLowercaseCharacters() -> Bool {
        return stringFulfillsRegex(regex: ".*[a-z].*")
    }

    func hasNumbers() -> Bool {
        return stringFulfillsRegex(regex: ".*[0-9].*")
    }

    func hasSpecialCharacters() -> Bool {
        return stringFulfillsRegex(regex: ".*[^A-Za-z0-9].*")
    }

    func isValidEmail() -> Bool {
        return stringFulfillsRegex(regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    }

    func isPhoneNumValid() -> Bool {
        return stringFulfillsRegex(regex: "^[0-9+]{0,1}+[0-9]{5,16}$")
    }

    private func stringFulfillsRegex(regex: String) -> Bool {
        let texttest = NSPredicate(format: "SELF MATCHES %@", regex)
        guard texttest.evaluate(with: self) else {
            return false
        }
        return true
    }
}
