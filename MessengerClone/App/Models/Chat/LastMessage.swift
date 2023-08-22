//
//  ChatRoomModel.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/24/23.
//

import FirebaseAuth
import FirebaseDatabaseSwift
import GRDB
import UIKit

// MARK: - Types / Properties
struct Member: Codable, Hashable {
    var userId: String
    var seenMessage: Bool
}

enum ChatType: String {
    case oneToOne
    case group
}

enum ChatMessageType: String {
    case text
    case like
    case picture
    case video
    case voice
    case file
}

// MARK: - LVL 1
struct LastMessage: Codable, Hashable {
    var id: String { chatRoomId }
    var chatRoomId: String
    var chatType: ChatType.RawValue
    var title: String?

    // message
    var lastMessage: String
    var messageType: ChatMessageType.RawValue
    var lastMessageId: String
    var fromId: String
    var fromName: String // For easier notifications query in Firebase Functions

    // timeStamp / date
    var timestamp: Int

    // members
    var members: [Member]
}

