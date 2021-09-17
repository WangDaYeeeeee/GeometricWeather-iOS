//
//  CornerButton.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import Foundation

private let touchDownAnimDuration = 0.1
private let touchUpAnimDuration = 0.5

private let touchDownAlpha = 0.5

class CornerButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        get {
            let superSize = super.intrinsicContentSize
            return CGSize(
                width: superSize.width + 2 * littleMargin,
                height: superSize.height + littleMargin
            )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = min(
            self.frame.width,
            self.frame.height
        ) / 2.0
    }
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: touchDownAnimDuration) {
            self.titleLabel?.alpha = touchDownAlpha
        }
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.titleLabel?.alpha = 1.0
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.titleLabel?.alpha = 1.0
        }
    }
}
