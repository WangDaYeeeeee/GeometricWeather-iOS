//
//  CornerButton.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import Foundation
import GeometricWeatherBasic

private let touchDownAnimDuration = 0.4
private let touchUpAnimDuration = 0.6

private let touchDownAlpha = 0.5
private let touchDownScale = 1.1

class CornerButton: UIButton {
    
    private var intrinsicContentSizeCache: CGSize?
    
    override var intrinsicContentSize: CGSize {
        get {
            let superSize = super.intrinsicContentSize
            let size = CGSize(
                width: superSize.width + 2 * littleMargin,
                height: superSize.height + littleMargin
            )
            
            if self.intrinsicContentSizeCache != size {
                self.intrinsicContentSizeCache = size
                self.layer.cornerRadius = min(size.width, size.height) / 2.0
            }
            
            return size
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: touchDownAnimDuration, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 4.0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.titleLabel?.alpha = touchDownAlpha
            self.transform = CGAffineTransform(scaleX: touchDownScale, y: touchDownScale)
        } completion: { _ in
            // do nothing.
        }
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: touchDownAnimDuration, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 4.0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.titleLabel?.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { _ in
            // do nothing.
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: touchDownAnimDuration, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 4.0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.titleLabel?.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { _ in
            // do nothing.
        }
    }
}
