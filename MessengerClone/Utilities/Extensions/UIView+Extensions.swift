//
//  UIView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/20/23.
//

import UIKit

// MARK: - Constraints
extension UIView {
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        paddingTop: CGFloat = 0,
        bottom: NSLayoutYAxisAnchor? = nil,
        paddingBottom: CGFloat = 0,
        left: NSLayoutXAxisAnchor? = nil,
        paddingLeft: CGFloat = 0,
        right: NSLayoutXAxisAnchor? = nil,
        paddingRight: CGFloat = 0,
        height: NSLayoutDimension? = nil,
        width: NSLayoutDimension? = nil,
        heightConstant: CGFloat = 0,
        widthConstant: CGFloat = 0,
        centerX: NSLayoutXAxisAnchor? = nil,
        centerY: NSLayoutYAxisAnchor? = nil
    ) {
        if let top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let height {
            heightAnchor.constraint(equalTo: height).isActive = true
        }
        if let width {
            widthAnchor.constraint(equalTo: width).isActive = true
        }
        if widthConstant != 0 {
            widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        }
        if heightConstant != 0 {
            heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
        if let centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }

    /// Left and right anchor
    func pin(to superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }

    func pinWithSafeArea(to superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    func pinVertical(to superView: UIView, padding: CGFloat = 0) {
        topAnchor.constraint(equalTo: superView.topAnchor, constant: padding).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -padding).isActive = true
    }

    func pinSides(to superView: UIView, padding: CGFloat = 0) {
        leftAnchor.constraint(equalTo: superView.leftAnchor, constant: padding).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -padding).isActive = true
    }
}

// MARK: - Animations
extension UIView {
    func defaultAnimation(_ action: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut
        ) {
            action()
        }
    }

    func spring(_ completionBlock: @escaping () -> Void) {
        guard transform.isIdentity else { return }
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) { [weak self] in
            self?.transform = .init(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) { [weak self] in
                self?.transform = .init(scaleX: 1, y: 1)
            } completion: { _ in
                completionBlock()
            }
        }
    }
}

// MARK: - Round corners
extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// MARK: - Custom init
extension UIView {
    convenience init(withAutolayout: Bool) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = !withAutolayout
    }
}
