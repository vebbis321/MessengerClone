//
//  BaseTabVC.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/5/23.
//

import UIKit

public class BasteTabViewController: UIViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

extension UIViewController {
    func admenuBtnForBaseTabViewContoller(action: Selector) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let image = UIImage(systemName: "line.3.horizontal", withConfiguration: config)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        navigationItem.leftBarButtonItem = button
    }
}
