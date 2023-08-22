//
//  MessageBarContainerView+ViewModel.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 6/24/23.
//

import Foundation

extension ChatContentViewController {
    struct MessageBarViewModel {
        var assetGridState: AssetGridState = .hidden
        var keyboardState: KeyboardState
        var keepWrapperActive = false

        init(keyboardHeight: CGFloat) {
            self.keyboardState = keyboardHeight == .zero ? .hidden : .show
        }

        func getState() -> WrapperState {
            if assetGridState == .hidden, keyboardState == .hidden {
                return .hidden
            } else {
                return .show
            }
        }

        func wrapperIsInactive() -> Bool {
            assetGridState == .hidden && keyboardState == .hidden
        }

        enum AssetGridState {
            case hidden
            case show

            var assetGridAlpha: CGFloat {
                return self == .show ? 1.0 : 0.0
            }

            var assetGridIsHidden: Bool {
                assetGridAlpha == 1.0 ? false : true
            }
        }

        enum KeyboardState {
            case hidden
            case show
        }
    }

    enum WrapperState {
        case hidden
        case show

        var wrapperAlpha: CGFloat {
            self == .show ? 1.0 : 0.0
        }

        var wrapperIsHidden: Bool {
            wrapperAlpha == 1.0 ? false : true
        }
    }
}
