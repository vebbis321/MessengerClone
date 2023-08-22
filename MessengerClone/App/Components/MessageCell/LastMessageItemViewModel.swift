//
//  MessageCellConfiguration+ViewModel.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import UIKit
import FirebaseAuth

struct LastMessageItemViewModel: Hashable {
    let item: LastMessage
    
    init(item: LastMessage) {
        self.item = item
    }
    
    // currentUser
    var sentByCurrentUser: Bool {
        item.fromId == Auth.auth().currentUser?.uid ? true : false
    }
    
    var seenByCurrentUser: Bool? {
        currentMember?.seenMessage
    }
    
    var currentMember: Member? {
        item.members.first(where: { $0.userId == Auth.auth().currentUser?.uid })
    }
    
    var date: Date {
        return item.timestamp.date
    }
    
    var messageType: ChatMessageType {
        ChatMessageType(rawValue: item.messageType) ?? .text
    }
    
    var chatNameFont: UIFont {
        if seenByCurrentUser ?? false {
            return .systemFont(ofSize: 20, weight: .regular)
        } else {
            return .systemFont(ofSize: 20, weight: .bold)
        }
    }
    
    var messageLabelFont: UIFont {
        if seenByCurrentUser ?? false {
            return .systemFont(ofSize: 14, weight: .light)
        } else {
            return .systemFont(ofSize: 14, weight: .bold)
        }
    }
    
    func getCachedUser() async throws -> CachedUser? {
        guard let uuid = item.members.first(where: { $0 != currentMember })?.userId else { return nil }
        
        let cachedUser = try await LocalDatabase.shared.readForId(uuid: uuid)
        return cachedUser
    }
}
