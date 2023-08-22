//
//  PeoplesVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import UIKit

final class PeoplesVC: UIViewController, UIGestureRecognizerDelegate {
    weak var coordinator: PeoplesTabCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue
    }
}
