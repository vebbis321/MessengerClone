//
//  ChatRoomContentConfiguration.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/10/23.
//

import UIKit

struct LastMessageCellConfiguration: ContentConfigurable {
    var viewModel: LastMessageItemViewModel?

    func makeContentView() -> UIView & UIContentView {
        guard let viewModel else { return LastMessageCellContentView(configuration: self) }

        switch viewModel.messageType {
        case .text:
            break
        case .like:
            break
        case .picture:
            break
        case .video:
            break
        case .voice:
            break
        case .file:
            break
        }
        return LastMessageCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> LastMessageCellConfiguration {
        guard let state = state as? UICellConfigurationState else {
            return self
        }

        let updateConfiguration = self

        return updateConfiguration
    }
}
