//
//  MoonPhaseView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/22.
//

import UIKit

private let innerMargin = 2.0

private let moonPhaseStrokeWidth = 2.0

class MoonPhaseView: UIView {
    
    // MARK: - properties.
    
    // data.
    
    var angle = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var lightColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    var darkColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }
    var borderColor = UIColor.green {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // sublayers.
    
    private let ovalLayer = CAShapeLayer()
    private let arcLayer = CAShapeLayer()
    private let circleLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        self.ovalLayer.lineCap = .round
        self.ovalLayer.lineWidth = moonPhaseStrokeWidth
        
        self.arcLayer.lineCap = .round
        self.arcLayer.lineWidth = moonPhaseStrokeWidth
        
        self.circleLayer.lineCap = .round
        self.circleLayer.lineWidth = moonPhaseStrokeWidth
        
        self.borderLayer.lineCap = .round
        self.borderLayer.lineWidth = moonPhaseStrokeWidth
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.ovalLayer.removeFromSuperlayer()
        self.arcLayer.removeFromSuperlayer()
        self.circleLayer.removeFromSuperlayer()
        self.borderLayer.removeFromSuperlayer()
        
        let centerPoint = CGPoint(
            x: self.frame.width / 2.0,
            y: self.frame.height / 2.0
        )
        let radius = (
            min(self.frame.width, self.frame.height) - 2 * innerMargin
        ) / 2.0
        let arcRect = CGRect.from(
            center: centerPoint,
            size: CGSize(width: radius * 2, height: radius * 2)
        )
        
        if self.angle == 0.0 { // 🌑
            self.setCircleLayer(asColor: self.darkColor, inRect: arcRect)
        } else if self.angle < 90.0 { // 🌒
            self.setCircleLayer(asColor: self.lightColor, inRect: arcRect)
            
            self.setArcLayer(
                asColor: self.darkColor,
                alignCenter: centerPoint,
                withRadius: radius,
                showAtLeftSide: true
            )
            
            self.setOvalLayer(
                asColor: self.darkColor,
                alignCenter: centerPoint,
                withRadius: radius,
                andRatio: cos(toRadians(self.angle))
            )
        } else if self.angle == 90.0 { // 🌓
            self.setCircleLayer(asColor: self.darkColor, inRect: arcRect)
            
            self.setArcLayer(
                asColor: self.lightColor,
                alignCenter: centerPoint,
                withRadius: radius,
                showAtLeftSide: false
            )
        } else if self.angle < 180.0 { // 🌔
            self.setCircleLayer(asColor: self.darkColor, inRect: arcRect)
            
            self.setArcLayer(
                asColor: self.lightColor,
                alignCenter: centerPoint,
                withRadius: radius,
                showAtLeftSide: false
            )
            
            self.setOvalLayer(
                asColor: self.lightColor,
                alignCenter: centerPoint,
                withRadius: radius,
                andRatio: sin(toRadians(self.angle - 90))
            )
        } else if self.angle == 180.0 { // 🌕
            self.setCircleLayer(asColor: self.lightColor, inRect: arcRect)
        } else if self.angle < 270.0 { // 🌖
            self.setCircleLayer(asColor: self.darkColor, inRect: arcRect)
            
            self.setArcLayer(
                asColor: self.lightColor,
                alignCenter: centerPoint,
                withRadius: radius,
                showAtLeftSide: true
            )
            
            self.setOvalLayer(
                asColor: self.lightColor,
                alignCenter: centerPoint,
                withRadius: radius,
                andRatio: cos(toRadians(self.angle - 180))
            )
        } else if self.angle == 270.0 { // 🌗
            self.setCircleLayer(asColor: self.lightColor, inRect: arcRect)
            
            self.setArcLayer(
                asColor: self.darkColor,
                alignCenter: centerPoint,
                withRadius: radius,
                showAtLeftSide: false
            )
        } else { // angle < 360. 🌘
            self.setCircleLayer(asColor: self.lightColor, inRect: arcRect)
            
            self.setArcLayer(
                asColor: self.darkColor,
                alignCenter: centerPoint,
                withRadius: radius,
                showAtLeftSide: false
            )
            
            self.setOvalLayer(
                asColor: self.darkColor,
                alignCenter: centerPoint,
                withRadius: radius,
                andRatio: cos(toRadians(360 - self.angle))
            )
        }
        
        self.borderLayer.path = UIBezierPath(ovalIn: arcRect).cgPath
        self.borderLayer.fillColor = UIColor.clear.cgColor
        self.borderLayer.strokeColor = self.borderColor.cgColor
        self.layer.addSublayer(self.borderLayer)
    }
    
    // MARK: - ui.
    
    private func setCircleLayer(
        asColor: UIColor,
        inRect: CGRect
    ) {
        self.circleLayer.path = UIBezierPath(ovalIn: inRect).cgPath
        self.circleLayer.fillColor = asColor.cgColor
        self.circleLayer.strokeColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(self.circleLayer)
    }
    
    private func setArcLayer(
        asColor color: UIColor,
        alignCenter center: CGPoint,
        withRadius radius: CGFloat,
        showAtLeftSide atLeft: Bool
    ) {
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: (atLeft ? 0.5 : 1.5) * .pi,
            endAngle: (atLeft ? 1.5 : 2.5) * .pi,
            clockwise: true
        )
        path.close()
        
        self.arcLayer.path = path.cgPath
        self.arcLayer.fillColor = color.cgColor
        self.arcLayer.strokeColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(self.arcLayer)
    }
    
    private func setOvalLayer(
        asColor color: UIColor,
        alignCenter center: CGPoint,
        withRadius radius: CGFloat,
        andRatio ratio: Double
    ) {
        let path = UIBezierPath(
            ovalIn: CGRect.from(
                center: center,
                size: CGSize(
                    width: (2 * radius - 0.8 * moonPhaseStrokeWidth) * ratio,
                    height: 2 * radius - 0.8 * moonPhaseStrokeWidth
                )
            )
        )
        
        self.ovalLayer.path = path.cgPath
        self.ovalLayer.fillColor = color.cgColor
        self.ovalLayer.strokeColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(self.ovalLayer)
    }
}

private func toRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180.0
}
