//
//  UIImage+Factory.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 7/8/23.
//

import UIKit

// MARK: - Custom init
extension UIImageView {
    convenience init(named name: String, contentMode: UIImageView.ContentMode = .scaleToFill) {
        let image = UIImage(named: name)

        self.init(image: image)
        self.contentMode = contentMode
        translatesAutoresizingMaskIntoConstraints = false
    }
}
