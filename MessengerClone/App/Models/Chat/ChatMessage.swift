//
//  ChatMessage.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/22/23.
//

import FirebaseAuth
import Foundation

struct ChatMessage: Codable, Identifiable, Hashable {
    // id
    var id: String { messageId }
    var messageId: String
    var chatRoomId: String
    var title: String?

    // message
    var message: String
    var messageType: ChatMessageType.RawValue
    var fromId: String

    // currentUser
    var sentByCurrentUser: Bool {
        fromId == Auth.auth().currentUser?.uid ? true : false
    }

    // timeStamp / date
    var timestamp: Int
    var date: Date {
        timestamp.date
    }
}
