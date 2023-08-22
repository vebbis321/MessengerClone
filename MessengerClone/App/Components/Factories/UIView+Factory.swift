//
//  UIView+Factory.swift
//  MessengerClone
//
//  Created by Vebjørn Daniloff on 8/10/23.
//

import UIKit

extension UIView {
    // MARK: - Spacer
    static func createSpacer() -> UIView {
        let view = UIView(withAutolayout: true)
        let spacerWidthConstr = view.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstr.priority = .defaultLow
        spacerWidthConstr.isActive = true
        return view
    }
}
