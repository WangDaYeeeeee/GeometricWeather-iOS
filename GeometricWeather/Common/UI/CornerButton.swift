//
//  CornerButton.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import Foundation
import GeometricWeatherBasic
import SwiftUI

private let touchDownAnimDuration = 0.4
private let touchUpAnimDuration = 0.6

private let touchDownAlpha = 0.5
private let touchDownScale = 0.95

// MARK: - ui view.

class CornerButton: UIButton {
    
    // MARK: - inner data.
        
    private var intrinsicContentSizeCache = CGSize.zero
    override var intrinsicContentSize: CGSize {
        get {
            let superSize = super.intrinsicContentSize
            let size = self.isLittleMargins
            ? CGSize(
                width: superSize.width + 16.0,
                height: superSize.height + 2.0
            )
            : CGSize(
                width: superSize.width + 2 * littleMargin,
                height: superSize.height + littleMargin
            )
            
            if !self.intrinsicContentSizeCache.equalTo(size) {
                self.intrinsicContentSizeCache = size
                
                let path = UIBezierPath(
                    roundedRect: CGRect(origin: .zero, size: size),
                    cornerRadius: min(size.width, size.height) / 2.0
                )
                
                self.cornerBackgroundLayer.path = path.cgPath
                self.cornerBackgroundLayer.shadowPath = path.cgPath
                
                self.cornerBackgroundLayer.frame = CGRect(origin: .zero, size: size)
            }
            
            return size
        }
    }
    
    private var isLittleMargins: Bool
    
    private var cornerBackgroundColor: UIColor? {
        didSet {
            self.cornerBackgroundLayer.fillColor = self.cornerBackgroundColor?.cgColor
            self.cornerBackgroundLayer.shadowColor = self.cornerBackgroundColor?.cgColor
        }
    }
    override var backgroundColor: UIColor? {
        set {
            self.cornerBackgroundColor = newValue
        }
        get {
            return self.cornerBackgroundColor
        }
    }
    
    // MARK: - sublayers.
    
    private let cornerBackgroundLayer = CAShapeLayer()
    
    // MARK: - life cycles.
    
    init(frame: CGRect, useLittleMargin: Bool = false) {
        self.isLittleMargins = useLittleMargin
        super.init(frame: frame)
        
        self.cornerBackgroundLayer.zPosition = -1
        self.cornerBackgroundLayer.strokeColor = UIColor.clear.cgColor
        self.cornerBackgroundLayer.cornerRadius = 4.0
        self.cornerBackgroundLayer.shadowOpacity = 0.5
        self.cornerBackgroundLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.addSublayer(self.cornerBackgroundLayer)
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycles.
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        self.cornerBackgroundLayer.position = CGPoint(
            x: layer.frame.width / 2.0,
            y: layer.frame.height / 2.0
        )
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.backgroundColor = self?.backgroundColor
        }
    }
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        UIView.animate(
            withDuration: touchDownAnimDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 4.0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.titleLabel?.alpha = touchDownAlpha
            
            let transform = CGAffineTransform(scaleX: touchDownScale, y: touchDownScale)
            self.cornerBackgroundLayer.setAffineTransform(transform)
        } completion: { _ in
            // do nothing.
        }
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(
            withDuration: touchDownAnimDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 4.0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.titleLabel?.alpha = 1.0
            
            let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.cornerBackgroundLayer.setAffineTransform(transform)
        } completion: { _ in
            // do nothing.
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(
            withDuration: touchDownAnimDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 4.0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.titleLabel?.alpha = 1.0
            
            let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.cornerBackgroundLayer.setAffineTransform(transform)
        } completion: { _ in
            // do nothing.
        }
    }
}
