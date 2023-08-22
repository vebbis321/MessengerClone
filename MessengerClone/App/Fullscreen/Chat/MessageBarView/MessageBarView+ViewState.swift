//
//  MessageBarView+ViewState.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import Foundation

extension MessageBarView {
    enum ViewState: Equatable {
        private var value: String? {
            return String(describing: self).components(separatedBy: "(").first
        }

        private static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            lhs.value == rhs.value
        }

        case textIsActive(Height, NumberOfLines)
        case didEndEdit(Height)

        case showLeftForTextBtns(Height)
        case hideLeftForTextBtns(Height, NumberOfLines)
    }
}
