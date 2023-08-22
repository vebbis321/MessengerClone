//
//  UIKitProgressView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/14/23.
//

import UIKit

// from: https://betterprogramming.pub/lets-build-a-circular-loading-indicator-in-swift-5-b06fcdf1260d
final class SpinnerView: UIView {
    // MARK: - properties
    private let colors: [UIColor]
    private let lineWidth: CGFloat

    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = colors[0].cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        return shapeLayer
    }()

    private lazy var strokeColoAnimtaion: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "strokeColor"
        animation.values = colors.map { $0.cgColor }
        animation.repeatCount = .greatestFiniteMagnitude
        animation.timingFunction = .init(name: .easeInEaseOut)
        return animation
    }()

    var isAnimating = false {
        didSet {
            if isAnimating {
                animateStroke()
                animateRotation()
            } else {
                shapeLayer.removeFromSuperlayer()
                layer.removeAllAnimations()
            }
        }
    }

    // MARK: - init
    init(frame: CGRect, colors: [UIColor], lineWidth: CGFloat) {
        self.colors = colors
        self.lineWidth = lineWidth

        super.init(frame: frame)

        self.backgroundColor = .clear
    }

    convenience init(colors: [UIColor], lineWidth: CGFloat) {
        self.init(frame: .zero, colors: colors, lineWidth: lineWidth)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.width / 2

        let path = UIBezierPath(
            ovalIn: .init(
                x: 0,
                y: 0,
                width: bounds.width,
                height: bounds.height
            )
        )

        shapeLayer.path = path.cgPath
    }

    // MARK: - Animations
    private func animateStroke() {
        let startAnimation = StrokeAnimation(
            type: .start,
            beginTime: 0.25,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )

        let endAnimation = StrokeAnimation(
            type: .end,
            fromValue: 0.0,
            toValue: 1.0,
            duration: 0.75
        )

        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [startAnimation, endAnimation]

        shapeLayer.add(strokeAnimationGroup, forKey: nil)

        strokeColoAnimtaion.duration = strokeAnimationGroup.duration * Double(colors.count)
        shapeLayer.add(strokeColoAnimtaion, forKey: nil)
        layer.addSublayer(shapeLayer)
    }

    private func animateRotation() {
        let rotationAnimation = RotaionAnimation(
            direction: .z,
            fromValue: 0,
            toValue: CGFloat.pi * 2,
            duration: 2,
            repeatCount: .greatestFiniteMagnitude
        )

        layer.add(rotationAnimation, forKey: nil)
    }
}

// MARK: - SttrokeAnimation
final class StrokeAnimation: CABasicAnimation {
    enum StrokeType {
        case start
        case end
    }

    override init() {
        super.init()
    }

    init(
        type: StrokeType,
        beginTime: Double = 0.0,
        fromValue: CGFloat,
        toValue: CGFloat,
        duration: Double
    ) {
        super.init()

        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"

        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SttrokeAnimation
final class RotaionAnimation: CABasicAnimation {
    enum Direction: String {
        case x
        case y
        case z
    }

    override init() {
        super.init()
    }

    init(
        direction: Direction,
        fromValue: CGFloat,
        toValue: CGFloat,
        duration: Double,
        repeatCount: Float
    ) {
        super.init()

        self.keyPath = "transform.rotation.\(direction.rawValue)"

        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.repeatCount = repeatCount
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
