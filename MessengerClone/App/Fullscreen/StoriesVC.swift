//
//  StoriesVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/16/23.
//

import UIKit

final class StoriesVC: UIViewController, UIGestureRecognizerDelegate {
    weak var coordinator: StoriesTabCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
    }
}
