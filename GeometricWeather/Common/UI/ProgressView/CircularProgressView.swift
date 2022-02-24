//
//  CircularProgressView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/19.
//

import UIKit
import GeometricWeatherBasic

private let progressAnimationKey = "progress_animation"

private let innerMargin = 6.0

private let circularProgressShadowZ = 0.0
private let circularProgressProgressZ = 1.0
private let circularProgressSubviewsZ = 2.0

private let circularProgressProgressWidth = 12.0
private let circularProgressShadowAlpha = 0.1

class CircularProgressView: UIView {
    
    // MARK: - properties.
    
    // data.
    
    // 0 - 1.
    private(set) var progress = 0.0
    private(set) var colors = (from: UIColor.clear, to: UIColor.clear)
    private var durationCache = 0.0
    
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
            
            self.sizeCache = .zero
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
        if sizeCache == self.frame.size {
            return
        }
        sizeCache = self.frame.size
        
        self.setProgress(
            self.progress,
            withAnimationDuration: self.durationCache,
            value: self.progressValue,
            andDescription: self.progressDescription,
            betweenColors: self.colors
        )
        
        self.progressValueLabel.frame = self.bounds
        
        self.progressDescriptionLabel.center = CGPoint(
            x: self.frame.width / 2.0,
            y: 0
        )
        self.progressDescriptionLabel.frame.origin = CGPoint(
            x: self.progressDescriptionLabel.frame.origin.x,
            y: self.frame.height - innerMargin - self.progressDescriptionLabel.frame.height
        )
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
        self.progress = progress
        self.colors = betweenColors
        self.durationCache = withAnimationDuration
        
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
        self.shadowShape.path = path.cgPath
        self.shadowShape.strokeStart = 0.0
        self.shadowShape.strokeEnd = 1.0
        self.shadowShape.strokeColor = betweenColors.to.withAlphaComponent(
            circularProgressShadowAlpha
        ).cgColor
        
        self.progressShape.path = path.cgPath
        self.progressShape.strokeStart = 0.0
        
        if withAnimationDuration == 0 {
            self.progressShape.removeAllAnimations()
            
            self.progressShape.strokeEnd = progress
            self.progressShape.strokeColor = betweenColors.to.cgColor
            return
        }
        
        self.progressValueLabel.countFromZero(
            to: CGFloat(value),
            withDuration: withAnimationDuration
        )
        
        self.progressShape.strokeEnd = 0.0
        self.progressShape.strokeColor = betweenColors.from.cgColor
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.toValue = progress
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.toValue = betweenColors.to.cgColor
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = withAnimationDuration
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(controlPoints: 0.9, 0.05, 0.1, 0.95)
        animationGroup.animations = [pathAnimation, colorAnimation]
        self.progressShape.add(animationGroup, forKey: progressAnimationKey)
    }
}
