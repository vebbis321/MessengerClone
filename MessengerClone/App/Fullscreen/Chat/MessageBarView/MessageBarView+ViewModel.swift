//
//  MessageBarView+ViewModel.swift
//  MessengerClone
//
//  Created by Vebjorn Daniloff on 8/22/23.
//

import Foundation

extension MessageBarView {
    struct ViewModel {
        private let maxNumberOfLines: Int = 5
        private var heightFor5Lines: CGFloat = .zero
        var viewState: ViewState = .didEndEdit(0)

        mutating func getTextViewHeight() -> CGFloat {
            switch viewState {
            case let .hideLeftForTextBtns(height, numberOfLines), let .textIsActive(height, numberOfLines):

                if Int(numberOfLines) > 5 {
                    return heightFor5Lines
                } else {
                    if Int(numberOfLines) == 5 {
                        heightFor5Lines = height
                    }
                    return height
                }

            case let .didEndEdit(height), let .showLeftForTextBtns(height):
                return height
            }
        }

        var hideLeftBarBtns: Bool {
            switch viewState {
            case .didEndEdit, .showLeftForTextBtns:
                return false
            default:
                return true
            }
        }

        var scrollToBottom: Bool {
            switch viewState {
            case .hideLeftForTextBtns:
                return true
            default:
                return false
            }
        }

        var leftForTxtBtnsAlpha: CGFloat {
            hideLeftBarBtns ? 0.0 : 1.0
        }

        var chevronAlpha: CGFloat {
            hideLeftBarBtns ? 1.0 : 0.0
        }
    }
}
