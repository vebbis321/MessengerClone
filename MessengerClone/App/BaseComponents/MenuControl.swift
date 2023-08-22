//
//  MenuControl.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/28/23.
//

import UIKit

class MenuControl: UIControl {
    var customMenu: UIMenu

    // MARK: Initialization
    init(menu: UIMenu) {
        self.customMenu = menu
        super.init(frame: .zero)
        isContextMenuInteractionEnabled = true
        showsMenuAsPrimaryAction = true
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ContextMenu
    override func contextMenuInteraction(_: UIContextMenuInteraction, configurationForMenuAtLocation _: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [weak self] _ in
            self?.customMenu
        })
    }
}
