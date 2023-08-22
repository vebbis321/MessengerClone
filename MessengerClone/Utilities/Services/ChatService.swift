//
//  ChatService.swift
//  MessengerClone
//
//  Created by Vebjørn Daniloff on 8/21/23.
//

import FirebaseAuth
import FirebaseDatabase
import FireThelRealtimeDatabase
import Combine

protocol ChatServiceProtocol {
    func sendMessageInOneToOneChat(
        with recipient: UserPublic,
        message: String,
        messageType: ChatMessageType,
        isExistingChat: Bool
    ) async throws
}

// can use struct, but this is likely to grow with more message methods.
// better to pass a reference instead of a huge object
class ChatService: ChatServiceProtocol {
    private let db = Database.database().reference()

    // MARK: - Create
    func sendMessageInOneToOneChat(
        with recipient: UserPublic,
        message: String,
        messageType: ChatMessageType,
        isExistingChat: Bool
    ) async throws {

        guard let user = Auth.auth().currentUser, let name = user.displayName else {
            throw MessengerError.someThingWentWrong
        }

        let chatRoomId: String = .getChatId(userId: user.uid, recipientId: recipient.uuid)
        let messageId = db.child(.getPathToLastMessgae(chatRoomid: chatRoomId)).childByAutoId().key ?? UUID().uuidString

        // create lastMessage
        let messageRoom = LastMessage(
            chatRoomId: chatRoomId,
            chatType: ChatType.oneToOne.rawValue,
            lastMessage: message,
            messageType: messageType.rawValue,
            lastMessageId: messageId,
            fromId: user.uid,
            fromName: name,
            timestamp: Date().unixTimestamp,
            members: [
                .init(userId: user.uid, seenMessage: true),
                .init(userId: recipient.uuid, seenMessage: false),
            ]
        )

        // create chatMessages
        let chatMessage = ChatMessage(
            messageId: messageId,
            chatRoomId: chatRoomId,
            message: message,
            messageType: messageType.rawValue,
            fromId: user.uid,
            timestamp: Date().unixTimestamp
        )

        var data: [String: Codable] = [
            .getPathToChatMessage(chatRoomId: chatRoomId, messageId: messageId): chatMessage,
            .getPathToLastMessgae(chatRoomid: chatRoomId): messageRoom
        ]

        if isExistingChat == false {
            let chatRoom: ChatRoom = .init(chatRoomId: chatRoomId, isMember: true)
            data[.getPathToChatRooms(userId: user.uid, chatRoomId: chatRoomId)] = chatRoom
            data[.getPathToChatRooms(userId: recipient.uuid, chatRoomId: chatRoomId)] = chatRoom
        }

        try await db.performAtomicWrites(data: data)
    }

}
