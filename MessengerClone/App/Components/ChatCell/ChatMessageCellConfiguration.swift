//
//  ChatCellConfiguration.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/14/23.
//

import UIKit

struct ChatMessageCellConfiguration: ContentConfigurable {
    var viewModel: ChatMessageItemViewModel?

    func makeContentView() -> UIView & UIContentView {
        guard let viewModel, let messageType = ChatMessageType(rawValue: viewModel.item.messageType) else {
            return ChatTextCellContentView(configuration: self)
        }
        switch messageType {
        case .text:
            return ChatTextCellContentView(configuration: self)
        case .picture:
            return ChatImageCellContentView(configuration: self)
        default:
            return ChatTextCellContentView(configuration: self)
        }
    }

    func updated(for state: UIConfigurationState) -> ChatMessageCellConfiguration {
        guard let state = state as? UICellConfigurationState else {
            return self
        }

        // do something
        if state.isSelected {}

        let updateConfiguration = self

        return updateConfiguration
    }
}
