//
//  ChatMessageCellConfiguration+ViewModel.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import UIKit

struct ChatMessageItemViewModel: Hashable {
    var item: ChatMessage
    var isLastMessage = false
    var isPreviousMessageSentByCurrent = true

    var messageLabelTextColor: UIColor? {
        return item.sentByCurrentUser ? .white : .black
    }

    var textBackgroundColor: UIColor? {
        return item.sentByCurrentUser ? .theme.button : .theme.recipientMsgBubble
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(item.id)
        //        hasher.combine(isLastMessage)
    }
}
