//
//  UIView+Gradient.swift
//  ImageFeed
//
//  Created by Moxa on 31/03/26.
//

import UIKit

final class AnimatedGradientView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }

    private func setupGradient() {
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.masksToBounds = true
        layer.addSublayer(gradientLayer)

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientLayer.add(gradientChangeAnimation, forKey: "locationsChange")
    }
}

extension UIView {
    func addGradient() {
        // Предотвращаем дублирование
        if subviews.contains(where: { $0 is AnimatedGradientView }) { return }
        
        let gradientView = AnimatedGradientView(frame: bounds)
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientView.layer.cornerRadius = layer.cornerRadius
        gradientView.clipsToBounds = true
        addSubview(gradientView)
    }

    func removeGradient() {
        subviews.first(where: { $0 is AnimatedGradientView })?.removeFromSuperview()
    }
}
