//
//  PagerIndicator.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/3.
//

import UIKit
import GeometricWeatherBasic

private let defaultDotRadius = 4.0
private let defaultDotCenterMargin = defaultDotRadius * 2 + 6.0

class DotPagerIndicator: UIView {
    
    // MARK: - properties.
    
    // sizes.
    
    var dotRadius: CGFloat = defaultDotRadius {
        didSet {
            self.setNeedsLayout()
        }
    }
    var dotCenterMargin: CGFloat = defaultDotCenterMargin {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // colors.
    
    var selectedColor = UIColor.blue.cgColor {
        didSet {
            self.updateColorOfDots()
        }
    }
    var unselectedColor = UIColor.black.withAlphaComponent(0.5).cgColor {
        didSet {
            self.updateColorOfDots()
        }
    }
    
    // index.
    var selectedIndex = 0 {
        didSet {
            self.updateColorOfDots()
        }
    }
    var totalIndex = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // sublayers.
    
    private var dots = [CAShapeLayer]()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        for dotLayer in self.dots {
            dotLayer.removeFromSuperlayer()
        }
        dots.removeAll()
        
        if self.totalIndex < 1 {
            return
        }
        
        for i in 0 ..< self.totalIndex {
            let dotLayer = CAShapeLayer()
            dotLayer.path = UIBezierPath(
                ovalIn: CGRect.from(
                    center: self.getDotCenter(at: i),
                    size: CGSize(
                        width: 2 * self.dotRadius,
                        height: 2 * self.dotRadius
                    )
                )
            ).cgPath
            dotLayer.strokeColor = UIColor.clear.cgColor
            
            self.dots.append(dotLayer)
            self.layer.addSublayer(dotLayer)
        }
        self.updateColorOfDots()
    }
    
    // MARK: - ui.
    
    private func updateColorOfDots() {
        for i in 0 ..< self.dots.count {
            self.dots[i].fillColor = i == self.selectedIndex
            ? self.selectedColor
            : self.unselectedColor
        }
    }
    
    private func getDotCenter(at index: Int) -> CGPoint {
        let distanceBetweenCenterOfTwoSide = CGFloat(
            self.totalIndex - 1
        ) * self.dotCenterMargin
        
        return CGPoint(
            x: self.frame.size.width / 2.0
            - distanceBetweenCenterOfTwoSide / 2.0
            + CGFloat(index) * self.dotCenterMargin,
            y: self.frame.size.height / 2.0
        )
    }
}
