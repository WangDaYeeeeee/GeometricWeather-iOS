//
//  CircularProgressView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/19.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let progressAnimationKey = "progress_animation"
private let shadowAnimationKey = "shadow_animation"

private let innerMargin = 6.0

private let circularProgressShadowZ = 0.0
private let circularProgressProgressZ = 1.0
private let circularProgressSubviewsZ = 2.0

private let circularProgressProgressWidth = 12.0
private let circularProgressShadowAlpha = 0.1

private let shadowOpacity = 0.5

class CircularProgressView: UIView {
    
    // MARK: - properties.
    
    // data.
    
    // 0 - 1.
    private(set) var progress = 0.0
    private(set) var colors = (from: UIColor.clear, to: UIColor.clear)
    
    var progressValue: Int {
        get {
            return Int(self.progressValueLabel.text ?? "0") ?? 0
        }
        set {
            self.progressValueLabel.text = newValue.description
        }
    }
    var progressDescription: String {
        get {
            return self.progressDescriptionLabel.text ?? ""
        }
        set {
            if newValue == self.progressDescriptionLabel.text {
                return
            }
            
            self.progressDescriptionLabel.text = newValue
            self.progressDescriptionLabel.sizeToFit()
            
            self.setNeedsLayout()
        }
    }
    
    private var sizeCache = CGSize.zero
    
    // sublayers.
    
    private let progressShape = CAShapeLayer()
    private let shadowShape = CAShapeLayer()
    
    // subviews.
    
    private let progressValueLabel = UICountingLabel(frame: .zero)
    private let progressDescriptionLabel = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // sublayers.
        
        self.progressShape.lineCap = .round
        self.progressShape.lineWidth = circularProgressProgressWidth
        self.progressShape.strokeColor = UIColor.systemBlue.cgColor
        self.progressShape.fillColor = UIColor.clear.cgColor
        self.progressShape.zPosition = circularProgressProgressZ
        self.progressShape.shadowOffset = CGSize(width: 0, height: 4.0)
        self.progressShape.shadowRadius = 6.0
        self.layer.addSublayer(self.progressShape)
        
        self.shadowShape.lineCap = .round
        self.shadowShape.lineWidth = circularProgressProgressWidth
        self.shadowShape.strokeColor = UIColor.systemBlue.withAlphaComponent(
            circularProgressShadowAlpha
        ).cgColor
        self.shadowShape.fillColor = UIColor.clear.cgColor
        self.shadowShape.zPosition = circularProgressShadowZ
        self.layer.addSublayer(self.shadowShape)
        
        // subviews.
        
        self.progressValueLabel.font = UIFont.systemFont(ofSize: 42.0, weight: .medium)
        self.progressValueLabel.textColor = .label
        self.progressValueLabel.sizeToFit()
        self.progressValueLabel.textAlignment = .center
        self.progressValueLabel.method = .easeInOut
        self.progressValueLabel.format = "%d"
        self.addSubview(self.progressValueLabel)
        
        self.progressDescriptionLabel.font = captionFont
        self.progressDescriptionLabel.textColor = .secondaryLabel
        self.progressDescriptionLabel.sizeToFit()
        self.addSubview(self.progressDescriptionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.progressValueLabel.frame = self.bounds
        
        self.progressDescriptionLabel.center = CGPoint(
            x: self.frame.width / 2.0,
            y: 0
        )
        self.progressDescriptionLabel.frame.origin = CGPoint(
            x: self.progressDescriptionLabel.frame.origin.x,
            y: self.frame.height - innerMargin - self.progressDescriptionLabel.frame.height
        )
        
        if self.sizeCache == .zero {
            self.sizeCache = self.frame.size
            return
        }
        
        if self.sizeCache != self.frame.size {
            self.sizeCache = self.frame.size
            self.setProgress(
                self.progress,
                withAnimationDuration: 0.0,
                value: self.progressValue,
                andDescription: self.progressDescription,
                betweenColors: self.colors
            )
        }
    }
    
    // MARK: - interfaces.
    
    // progress: 0 - 1.
    // duration: 0 = no animation, otherwise execute an animation.
    // colors: count = 2, store the begin color and end color.
    func setProgress(
        _ progress: Double,
        withAnimationDuration: TimeInterval,
        value: Int,
        andDescription: String,
        betweenColors: (from: UIColor, to: UIColor)
    ) {
        self.layoutIfNeeded()
        
        self.progressShape.removeAllAnimations()
        
        self.progress = progress
        self.colors = betweenColors
        
        self.progressValue = value
        self.progressDescription = andDescription
        
        let path = UIBezierPath(
            arcCenter: CGPoint(
                x: self.frame.width / 2.0,
                y: self.frame.height / 2.0
            ),
            radius: self.frame.width / 2.0 - innerMargin - circularProgressProgressWidth / 2,
            startAngle: 0.75 * .pi,
            endAngle: 2.25 * .pi,
            clockwise: true
        )
        let shadowPath = UIBezierPath(
            arcCenter: CGPoint(
                x: self.frame.width / 2.0,
                y: self.frame.height / 2.0
            ),
            radius: self.frame.width / 2.0 - innerMargin - circularProgressProgressWidth / 2,
            startAngle: 0.75 * .pi,
            endAngle: (0.75 + (2.25 - 0.75) * progress) * .pi,
            clockwise: true
        )
        
        self.shadowShape.path = path.cgPath
        self.shadowShape.strokeStart = 0.0
        self.shadowShape.strokeEnd = 1.0
        self.shadowShape.strokeColor = betweenColors.to.withAlphaComponent(
            circularProgressShadowAlpha
        ).cgColor
        
        self.progressShape.path = path.cgPath
        self.progressShape.strokeStart = 0.0
        
        if withAnimationDuration == 0 {
            self.progressShape.strokeEnd = progress
            self.progressShape.strokeColor = betweenColors.to.cgColor
            
            self.progressShape.shadowOpacity = Float(shadowOpacity)
            self.progressShape.shadowPath = shadowPath.cgPath.copy(
                strokingWithWidth: self.progressShape.lineWidth,
                lineCap: .round,
                lineJoin: .miter,
                miterLimit: 0.0
            )
            self.progressShape.shadowColor = betweenColors.to.cgColor
            return
        }
        
        self.progressValueLabel.countFromZero(
            to: CGFloat(value),
            withDuration: withAnimationDuration
        )
        
        self.progressShape.strokeEnd = 0.0
        self.progressShape.strokeColor = betweenColors.from.cgColor
        self.progressShape.shadowOpacity = 0.0
        self.progressShape.shadowColor = betweenColors.from.cgColor
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.toValue = progress
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.toValue = betweenColors.to.cgColor
        
        let shadowPathAnimation = CABasicAnimation(keyPath: "shadowPath")
        shadowPathAnimation.fromValue = self.getAnimationPath(for: 0).cgPath.copy(
            strokingWithWidth: self.progressShape.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0.0
        )
        shadowPathAnimation.toValue = self.getAnimationPath(for: progress).cgPath.copy(
            strokingWithWidth: self.progressShape.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0.0
        )
        
        let shadowColorAnimation = CABasicAnimation(keyPath: "shadowColor")
        shadowColorAnimation.toValue = betweenColors.to.cgColor
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = withAnimationDuration
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.9, 0.1, 0.0, 1.0)
        animationGroup.animations = [
            pathAnimation,
            colorAnimation,
            shadowPathAnimation,
            shadowColorAnimation,
        ]
        self.progressShape.add(animationGroup, forKey: progressAnimationKey)
        
        let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowOpacityAnimation.toValue = Float(shadowOpacity)
        shadowOpacityAnimation.duration = withAnimationDuration * 0.33
        shadowOpacityAnimation.beginTime = CACurrentMediaTime() + withAnimationDuration * 0.66
        shadowOpacityAnimation.fillMode = .forwards
        shadowOpacityAnimation.isRemovedOnCompletion = false
        self.progressShape.add(shadowOpacityAnimation, forKey: shadowAnimationKey)
    }
    
    private func getAnimationPath(for progress: Double) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: self.getCircularAnimKeyFramePoint(for: 0))
        if Int(1.5 * 180.0 * progress) <= 1 {
            path.addLine(to: self.getCircularAnimKeyFramePoint(for: 1))
        } else {
            for angle in 1 ... Int(1.5 * 180.0 * progress) {
                path.addLine(to: self.getCircularAnimKeyFramePoint(for: angle))
            }
        }
        
        return path
    }
    
    private func getCircularAnimKeyFramePoint(for angle: Int) -> CGPoint {
        let radius = self.frame.width / 2.0 - innerMargin - circularProgressProgressWidth / 2
        let center = CGPoint(
            x: self.frame.width / 2.0,
            y: self.frame.height / 2.0
        )
        
        if angle < 45 {
            return CGPoint(
                x: center.x - radius * cos(Double(45 - angle) * .pi / 180.0),
                y: center.y + radius * sin(Double(45 - angle) * .pi / 180.0)
            )
        }
        if angle == 45 {
            return CGPoint(
                x: center.x - radius,
                y: center.y
            )
        }
        if angle < 45 + 90 {
            return CGPoint(
                x: center.x - radius * cos(Double(angle - 45) * .pi / 180.0),
                y: center.y - radius * sin(Double(angle - 45) * .pi / 180.0)
            )
        }
        if angle == 45 + 90 {
            return CGPoint(
                x: center.x,
                y: center.y - radius
            )
        }
        if angle < 45 + 90 + 90 {
            return CGPoint(
                x: center.x + radius * cos(Double(180 + 45 - angle) * .pi / 180.0),
                y: center.y - radius * sin(Double(180 + 45 - angle) * .pi / 180.0)
            )
        }
        if angle == 45 + 90 + 90 {
            return CGPoint(
                x: center.x + radius,
                y: center.y
            )
        }
        return CGPoint(
            x: center.x + radius * cos(Double(angle - 180 - 45) * .pi / 180.0),
            y: center.y + radius * sin(Double(angle - 180 - 45) * .pi / 180.0)
        )
    }
}
