//
//  UIColor.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/13/23.
//

import UIKit

extension UIColor {
    static let theme = MessengerColorTheme()
}

struct MessengerColorTheme {
    let sepearator = UIColor(named: "Seperator")
    let border = UIColor(named: "Border")
    let activeBorder = UIColor(named: "ActiveBorder")
    let background = UIColor(named: "Background")
    let metaLogo = UIColor(named: "MetaLogo")
    let button = UIColor(named: "Button")
    let buttonText = UIColor(named: "ButtonText")
    let tintColor = UIColor(named: "TintColor")
    let placeholder = UIColor(named: "Placeholder")
    let floatingLabel = UIColor(named: "FloatingLabel")
    let hyperlink = UIColor(named: "Hyperlink")
    let alertText = UIColor(named: "AlertText")
    let moreRow = UIColor(named: "MoreRow")
    let arhiveRow = UIColor(named: "ArchiveRow")
    let searchBackground = UIColor(named: "SearchBackground")
    let iconBackground = UIColor(named: "IconBackground")
    let recipientMsgBubble = UIColor(named: "RecipientMsgBubble")
}
