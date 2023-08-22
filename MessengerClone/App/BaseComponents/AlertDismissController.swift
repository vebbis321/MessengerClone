//
//  AlertDismissController.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/28/23.
//

import UIKit

final class AlertDismissController: UIAlertController {
    var dimissHandler: (() -> Void)?

    override func viewWillDisappear(_ animated: Bool) {
        dimissHandler?()
        super.viewWillDisappear(animated)
    }
}
