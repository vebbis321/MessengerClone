//
//  ChatRoom.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/22/23.
//


import Foundation

// Represents a room that will be populated by a LastMessage
struct ChatRoom: Codable, Identifiable, Equatable {
    var id: String { chatRoomId }
    var chatRoomId: String
    var isMember: Bool
}
