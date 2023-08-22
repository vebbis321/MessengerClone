//
//  CallsVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import UIKit

final class CallsVC: BasteTabViewController, UIGestureRecognizerDelegate {

    weak var coordinator: CallsTabCoordinator?


    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calls"
    }
}
