//
//  Constants.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/15/23.
//

import UIKit

public func getWindowHeight() -> CGFloat {
    guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
        return 320
    }
    let windowHeight = window.frame.height
    return windowHeight
}

public func getWindowWidth() -> CGFloat {
    guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
        return 320
    }
    let windowWidth = window.frame.width
    return windowWidth
}
