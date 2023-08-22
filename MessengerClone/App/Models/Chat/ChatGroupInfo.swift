//
//  ChatRoomInfoModel.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/24/23.
//

import FirebaseAuth
import FirebaseDatabaseSwift
import Foundation

// MARK: - LVL 3
struct ChatGroupInfo: Codable, Identifiable {
    var id: String { chatRoomId }
    var chatRoomId: String
    var title: String?

    // members
    var members: [Member]

    // admin
    var adminId: String
    var adminName: String
}
