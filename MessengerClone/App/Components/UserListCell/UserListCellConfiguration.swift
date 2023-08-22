//
//  UserListCellConfiguration.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/10/23.
//

import UIKit

struct UserListCellConfiguration: ContentConfigurable {
    var viewModel: UserPublic?

    func makeContentView() -> UIView & UIContentView {
        return UserListCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> UserListCellConfiguration {
        guard let state = state as? UICellConfigurationState else {
            return self
        }

        let updateConfiguration = self

        if state.isSwiped {
            // swiped state
        }

        return updateConfiguration
    }
}
