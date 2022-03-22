//
//  SunMoonPathView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/21.
//

import UIKit

private let sunAnimationKey = "sun_animation"
private let moonAnimationKey = "moon_animation"

private let innerMargin = 16.0

private let iconSize = 24.0

private let backgroundZ = -1.0
private let moonPathProgressZ = 0.0
private let sunPathProgressZ = 1.0
private let moonIconZ = 2.0
private let sunIconZ = 3.0

private let sunMoonPathProgressWidth = 4.0
private let sunMoonPathBackgroundWidth = 1.0
private let sunMoonPathShadowAlpha = 0.1

private let shadowOpacity = 0.5

class SunMoonPathView: UIView {
    
    // MARK: - properties.
    
    // data.
    
    // 0 - 1.
    private(set) var sunProgress = 0.0
    private(set) var moonProgress = 0.0
    
    var sunColor: UIColor {
        get {
            return UIColor(
                cgColor: self.sunProgressShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.sunProgressShape.strokeColor = newValue.cgColor
            self.sunProgressShape.shadowColor = newValue.cgColor
        }
    }
    var moonColor: UIColor {
        get {
            return UIColor(
                cgColor: self.moonProgressShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.moonProgressShape.strokeColor = newValue.cgColor
            self.moonProgressShape.shadowColor = newValue.cgColor
        }
    }
    var backgroundLineColor: UIColor {
        get {
            return UIColor(
                cgColor: self.backgroundShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.backgroundShape.strokeColor = newValue.cgColor
        }
    }
    
    var sunIconImage: UIImage? {
        get {
            return self.sunIcon.image
        }
        set {
            self.sunIcon.image = newValue?.scaleToSize(
                CGSize(
                    width: iconSize,
                    height: iconSize
                )
            )
        }
    }
    var moonIconImage: UIImage? {
        get {
            return self.moonIcon.image
        }
        set {
            self.moonIcon.image = newValue?.scaleToSize(
                CGSize(
                    width: iconSize,
                    height: iconSize
                )
            )
        }
    }
    
    private var sizeCache = CGSize.zero
    
    // sublayers.
    
    private let sunProgressShape = CAShapeLayer()
    private let moonProgressShape = CAShapeLayer()
    private let backgroundShape = CAShapeLayer()
    
    // subviews.
    
    private let sunIcon = UIImageView(
        frame: CGRect(x: 0.0, y: 0.0, width: iconSize, height: iconSize)
    )
    private let moonIcon = UIImageView(
        frame: CGRect(x: 0.0, y: 0.0, width: iconSize, height: iconSize)
    )
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // sublayers.
        
        self.sunProgressShape.lineCap = .round
        self.sunProgressShape.lineWidth = sunMoonPathProgressWidth
        self.sunProgressShape.strokeColor = UIColor.systemBlue.cgColor
        self.sunProgressShape.fillColor = UIColor.clear.cgColor
        self.sunProgressShape.zPosition = sunPathProgressZ
        self.sunProgressShape.shadowOffset = CGSize(width: 0, height: 3.0)
        self.sunProgressShape.shadowRadius = 3.0
        self.layer.addSublayer(self.sunProgressShape)
        
        self.moonProgressShape.lineCap = .round
        self.moonProgressShape.lineWidth = sunMoonPathProgressWidth
        self.moonProgressShape.strokeColor = UIColor.systemBlue.cgColor
        self.moonProgressShape.fillColor = UIColor.clear.cgColor
        self.moonProgressShape.zPosition = moonPathProgressZ
        self.moonProgressShape.shadowOffset = CGSize(width: 0, height: 3.0)
        self.moonProgressShape.shadowRadius = 3.0
        self.layer.addSublayer(self.moonProgressShape)
        
        self.backgroundShape.lineCap = .round
        self.backgroundShape.lineWidth = sunMoonPathBackgroundWidth
        self.backgroundShape.strokeColor = UIColor.systemBlue.cgColor
        self.backgroundShape.fillColor = UIColor.clear.cgColor
        self.backgroundShape.lineDashPattern = [
            NSNumber(value: 4.0),
            NSNumber(value: 4.0)
        ]
        self.backgroundShape.zPosition = backgroundZ
        self.layer.addSublayer(self.backgroundShape)
        
        // subviews.
        
        self.sunIcon.contentMode = .scaleAspectFit
        self.sunIcon.layer.zPosition = sunIconZ
        self.sunIcon.alpha = 0.0
        self.addSubview(self.sunIcon)
        
        self.moonIcon.contentMode = .scaleAspectFit
        self.moonIcon.layer.zPosition = moonIconZ
        self.moonIcon.alpha = 0.0
        self.addSubview(self.moonIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if self.sizeCache == .zero {
            self.sizeCache = self.frame.size
            return
        }
        
        if self.sizeCache != self.frame.size {
            self.sizeCache = self.frame.size
            self.setProgress(
                (self.sunProgress, self.moonProgress),
                withAnimationDuration: (0.0, 0.0)
            )
        }
    }
    
    // MARK: - interfaces.
    
    // progress: 0 - 1 if there is a valid progress, negative value if no progress.
    // duration: 0 = no animation, otherwise execute an animation.
    func setProgress(
        _ progress: (sun: Double, moon: Double),
        withAnimationDuration: (sun: TimeInterval, moon: TimeInterval)
    ) {
        self.layoutIfNeeded()
        self.sunProgress = progress.sun
        self.moonProgress = progress.moon
        
        let validWidth = self.frame.width - 2 * innerMargin
        let validHeight = self.frame.height - innerMargin
        let swipeAngle = .pi - 2 * asin(
            (validWidth / 2.0 - validHeight) / (validWidth / 2.0)
        )
        let arcCenter = CGPoint(
            x: validWidth / 2.0 + innerMargin,
            y: max(
                validWidth / 2.0 + innerMargin,
                validHeight + innerMargin
            )
        )
        let arcRadius = validWidth / 2.0
        let startAngle = 1.5 * .pi - swipeAngle * 0.5
        let arcPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: arcRadius,
            startAngle: startAngle,
            endAngle: startAngle + swipeAngle,
            clockwise: true
        )
        
        self.setProgress(
            progress.sun,
            withAnimationDuration: withAnimationDuration.sun,
            forKey: sunAnimationKey,
            andCGPaths: (
                arcPath.cgPath,
                UIBezierPath(
                    arcCenter: arcCenter,
                    radius: arcRadius,
                    startAngle: startAngle,
                    endAngle: startAngle + progress.sun * swipeAngle,
                    clockwise: true
                ).cgPath
            ),
            forShapeLayer: self.sunProgressShape
        )
        self.setProgress(
            progress.moon,
            withAnimationDuration: withAnimationDuration.moon,
            forKey: moonAnimationKey,
            andCGPaths: (
                arcPath.cgPath,
                UIBezierPath(
                    arcCenter: arcCenter,
                    radius: arcRadius,
                    startAngle: startAngle,
                    endAngle: startAngle + progress.moon * swipeAngle,
                    clockwise: true
                ).cgPath
            ),
            forShapeLayer: self.moonProgressShape
        )
        
        self.setProgress(
            progress.sun,
            withAnimationDuration: withAnimationDuration.sun,
            forKey: sunAnimationKey,
            forIcon: self.sunIcon
        )
        self.setProgress(
            progress.moon,
            withAnimationDuration: withAnimationDuration.moon,
            forKey: moonAnimationKey,
            forIcon: self.moonIcon
        )

        arcPath.addLine(
            to: CGPoint(
                x: validWidth / 2.0 - sqrt(
                    pow(validWidth / 2.0, 2.0) - pow(validWidth / 2.0 - validHeight, 2.0)
                ) + innerMargin,
                y: self.frame.height
            )
        )
        self.backgroundShape.path = arcPath.cgPath
        self.backgroundShape.strokeStart = 0.0
        self.backgroundShape.strokeEnd = 1.0
    }
    
    private func setProgress(
        _ progress: Double,
        withAnimationDuration duration: TimeInterval,
        forKey key: String,
        andCGPaths paths: (arcPath: CGPath, shadowPath: CGPath),
        forShapeLayer layer: CAShapeLayer
    ) {
        layer.removeAllAnimations()
        let progress = progress.keepIn(range: 0.01...1)
        
        layer.path = paths.arcPath
        layer.strokeStart = 0.0
        
        if duration == 0 {
            layer.strokeEnd = progress
            
            layer.shadowOpacity = Float(shadowOpacity)
            layer.shadowPath = paths.shadowPath.copy(
                strokingWithWidth: layer.lineWidth,
                lineCap: .round,
                lineJoin: .miter,
                miterLimit: 0.0
            )
            return
        }
        
        layer.strokeEnd = 0.0
        layer.shadowOpacity = 0.0
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.toValue = progress
        
        let shadowPathAnimation = CABasicAnimation(keyPath: "shadowPath")
        shadowPathAnimation.fromValue = self.getAnimationPath(for: 0).cgPath.copy(
            strokingWithWidth: layer.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0.0
        )
        shadowPathAnimation.toValue = self.getAnimationPath(for: progress).cgPath.copy(
            strokingWithWidth: layer.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0.0
        )
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.9, 0.1, 0.0, 1.0)
        animationGroup.animations = [
            pathAnimation,
            shadowPathAnimation,
        ]
        layer.add(animationGroup, forKey: key)
        
        let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowOpacityAnimation.toValue = Float(shadowOpacity)
        shadowOpacityAnimation.duration = duration * 0.33
        shadowOpacityAnimation.beginTime = CACurrentMediaTime() + duration * 0.66
        shadowOpacityAnimation.fillMode = .forwards
        shadowOpacityAnimation.isRemovedOnCompletion = false
        layer.add(shadowOpacityAnimation, forKey: key + "-shadow")
    }
    
    private func setProgress(
        _ progress: Double,
        withAnimationDuration duration: TimeInterval,
        forKey key: String,
        forIcon icon: UIImageView
    ) {
        icon.alpha = progress < 0 ? 0.0 : 1.0
        let actualProgress = max(
            0,
            min(progress, 1)
        )
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = self.getAnimationPath(for: actualProgress).cgPath
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = Double(Int(actualProgress * 7)) * 2 * .pi
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = max(duration, 0.1)
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.9, 0.1, 0.0, 1.0)
        animationGroup.animations = [pathAnimation, rotationAnimation]
        
        icon.layer.add(animationGroup, forKey: key)
    }
    
    private func getAnimationPath(for progress: Double) -> UIBezierPath {
        let validWidth = self.frame.width - 2 * innerMargin
        let validHeight = self.frame.height - innerMargin
        let swipeAngle = (
            .pi - 2 * asin(
                (validWidth / 2.0 - validHeight) / (validWidth / 2.0)
            )
        ) * 180.0 / .pi
                
        let path = UIBezierPath()
        
        path.move(to: self.getIconPoint(for: 0))
        if Int(swipeAngle * progress) <= 1 {
            path.addLine(to: self.getIconPoint(for: 1))
        } else {
            for angle in 1 ... Int(swipeAngle * progress) {
                path.addLine(to: self.getIconPoint(for: angle))
            }
        }
        
        return path
    }
    
    private func getIconPoint(for angle: Int) -> CGPoint {
        
        let validWidth = self.frame.width - 2 * innerMargin
        let validHeight = self.frame.height - innerMargin
        let swipeAngle = (
            .pi - 2 * asin(
                (validWidth / 2.0 - validHeight) / (validWidth / 2.0)
            )
        ) * 180.0 / .pi
        let currentAngle = 90 - Int(swipeAngle * 0.5) + angle
        
        let radius = validWidth / 2.0
        let center = CGPoint(
            x: validWidth / 2.0 + innerMargin,
            y: max(
                validWidth / 2.0 + innerMargin,
                validHeight + innerMargin
            )
        )
        
        if currentAngle < 90 {
            return CGPoint(
                x: center.x - radius * cos(Double(currentAngle) * .pi / 180.0),
                y: center.y - radius * sin(Double(currentAngle) * .pi / 180.0)
            )
        }
        if currentAngle == 90 {
            return CGPoint(
                x: center.x,
                y: center.y - radius
            )
        }
        return CGPoint(
            x: center.x + radius * cos(Double(180 - currentAngle) * .pi / 180.0),
            y: center.y - radius * sin(Double(180 - currentAngle) * .pi / 180.0)
        )
    }
}
