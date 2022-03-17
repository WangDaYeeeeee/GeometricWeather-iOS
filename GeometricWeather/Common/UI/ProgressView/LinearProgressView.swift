//
//  LinearProgressView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/21.
//

import UIKit
import GeometricWeatherBasic

private let progressAnimationKey = "progress_animation"
private let shadowAnimationKey = "shadow_animation"

private let innerMargin = 2.0

private let circularProgressShadowZ = 0.0
private let circularProgressProgressZ = 1.0
private let circularProgressSubviewsZ = 2.0

private let circularProgressProgressWidth = 4.0
private let circularProgressShadowAlpha = 0.1

private let shadowOpacity = 0.5

class LinearProgressView: UIView {
    
    // MARK: - properties.
    
    // data.
    
    // 0 - 1.
    private(set) var progress = 0.0
    private(set) var colors = (from: UIColor.clear, to: UIColor.clear)
    
    var topDescription: String {
        get {
            return self.progressTopLabel.text ?? ""
        }
        set {
            if newValue == self.progressTopLabel.text {
                return
            }
            
            self.progressTopLabel.text = newValue
            self.progressTopLabel.sizeToFit()
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var bottomDiscription: String {
        get {
            return self.progressBottomLabel.text ?? ""
        }
        set {
            if newValue == self.progressBottomLabel.text {
                return
            }
            
            self.progressBottomLabel.text = newValue
            self.progressBottomLabel.sizeToFit()
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    private var sizeCache = CGSize.zero
    
    // sublayers.
    
    private let progressShape = CAShapeLayer()
    private let shadowShape = CAShapeLayer()
    
    // subviews.
    
    private let progressTopLabel = UILabel(frame: .zero)
    private let progressBottomLabel = UILabel(frame: .zero)
    
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
        self.progressShape.shadowOffset = CGSize(width: 0, height: 2.0)
        self.progressShape.shadowRadius = 3.0
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
        
        self.progressTopLabel.font = captionFont
        self.progressTopLabel.textColor = .label
        self.progressTopLabel.sizeToFit()
        self.addSubview(self.progressTopLabel)
        
        self.progressBottomLabel.font = miniCaptionFont
        self.progressBottomLabel.textColor = .secondaryLabel
        self.progressBottomLabel.sizeToFit()
        self.addSubview(self.progressBottomLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if sizeCache == self.frame.size {
            return
        }
        sizeCache = self.frame.size
        
        self.progressTopLabel.frame.origin = CGPoint(
            x: innerMargin,
            y: innerMargin
        )
        self.progressBottomLabel.frame.origin = CGPoint(
            x: self.frame.width - innerMargin - self.progressBottomLabel.frame.width,
            y: self.frame.height - innerMargin - self.progressBottomLabel.frame.height
        )
    }
    
    // MARK: - interfaces.
    
    // progress: 0 - 1.
    // duration: 0 = no animation, otherwise execute an animation.
    // colors: count = 2, store the begin color and end color.
    func setProgress(
        _ progress: Double,
        withAnimationDuration: TimeInterval,
        andDescription: (top: String, bottom: String)? = nil,
        betweenColors: (from: UIColor, to: UIColor)
    ) {
        self.progressShape.removeAllAnimations()
        
        self.progress = progress
        self.colors = betweenColors
        
        if let desc = andDescription {
            self.topDescription = desc.top
            self.bottomDiscription = desc.bottom
        }
        
        let path = UIBezierPath()
        path.move(
            to: CGPoint(
                x: innerMargin,
                y: self.frame.height / 2.0
            )
        )
        path.addLine(
            to: CGPoint(
                x: self.frame.width - innerMargin,
                y: self.frame.height / 2.0
            )
        )
        
        let shadowStartPath = UIBezierPath()
        shadowStartPath.move(
            to: CGPoint(
                x: innerMargin,
                y: self.frame.height / 2.0
            )
        )
        shadowStartPath.addLine(
            to: CGPoint(
                x: innerMargin + 1.0,
                y: self.frame.height / 2.0
            )
        )
        let shadowEndPath = UIBezierPath()
        shadowEndPath.move(
            to: CGPoint(
                x: innerMargin,
                y: self.frame.height / 2.0
            )
        )
        shadowEndPath.addLine(
            to: CGPoint(
                x: innerMargin + progress * (self.frame.width - 2 * innerMargin),
                y: self.frame.height / 2.0
            )
        )
        
        self.shadowShape.path = path.cgPath
        self.shadowShape.strokeStart = 0.0
        self.shadowShape.strokeEnd = 1.0
        self.shadowShape.strokeColor = betweenColors.to.withAlphaComponent(
            circularProgressShadowAlpha
        ).cgColor
        
        self.progressShape.path = self.shadowShape.path
        self.progressShape.strokeStart = 0.0
        
        if withAnimationDuration == 0 {
            self.progressShape.strokeEnd = progress
            self.progressShape.strokeColor = betweenColors.to.cgColor
            
            self.progressShape.shadowOpacity = Float(shadowOpacity)
            self.progressShape.shadowPath = shadowEndPath.cgPath.copy(
                strokingWithWidth: self.progressShape.lineWidth,
                lineCap: .round,
                lineJoin: .miter,
                miterLimit: 0.0
            )
            self.progressShape.shadowColor = betweenColors.to.cgColor
            return
        }
        
        self.progressShape.strokeEnd = 0.0
        self.progressShape.strokeColor = betweenColors.from.cgColor
        self.progressShape.shadowOpacity = 0.0
        self.progressShape.shadowColor = betweenColors.from.cgColor
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.toValue = progress
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.toValue = betweenColors.to.cgColor
        
        let shadowPathAnimation = CABasicAnimation(keyPath: "shadowPath")
        shadowPathAnimation.fromValue = shadowStartPath.cgPath.copy(
            strokingWithWidth: self.progressShape.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0.0
        )
        shadowPathAnimation.toValue = shadowEndPath.cgPath.copy(
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
}
