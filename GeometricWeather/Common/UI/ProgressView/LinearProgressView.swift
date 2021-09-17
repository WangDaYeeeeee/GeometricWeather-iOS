//
//  LinearProgressView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/21.
//

import UIKit

private let progressAnimationKey = "progress_animation"

private let innerMargin = 2.0

private let circularProgressShadowZ = 0.0
private let circularProgressProgressZ = 1.0
private let circularProgressSubviewsZ = 2.0

private let circularProgressProgressWidth = 4.0
private let circularProgressShadowAlpha = 0.1

class LinearProgressView: UIView {
    
    // MARK: - properties.
    
    // data.
    
    // 0 - 1.
    private var _progress = 0.0
    var progress: Double {
        get {
            return _progress
        }
    }
    private var _colors = (from: UIColor.clear, to: UIColor.clear)
    var colors: (from: UIColor, to: UIColor) {
        get {
            return _colors
        }
    }
    
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
        
        self.setProgress(
            self._progress, withAnimationDuration: 0.0,
            andDescription: (self.topDescription, self.bottomDiscription),
            betweenColors: self._colors
        )
        
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
        self._progress = progress
        self._colors = betweenColors
        
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
        
        self.shadowShape.path = path.cgPath
        self.shadowShape.strokeStart = 0.0
        self.shadowShape.strokeEnd = 1.0
        self.shadowShape.strokeColor = betweenColors.to.withAlphaComponent(
            circularProgressShadowAlpha
        ).cgColor
        
        self.progressShape.path = self.shadowShape.path
        self.progressShape.strokeStart = 0.0
        
        if withAnimationDuration == 0 {
            self.progressShape.removeAllAnimations()
            
            self.progressShape.strokeEnd = progress
            self.progressShape.strokeColor = betweenColors.to.cgColor
            return
        }
        
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
