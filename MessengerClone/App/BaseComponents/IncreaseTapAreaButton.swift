//
//  CustomIconBtn.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/15/23.
//

import UIKit

final class IncreaseTapAreaButton: UIButton {
    // MARK: - Increase tappable area
    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -15, dy: -15).contains(point)
    }
}
