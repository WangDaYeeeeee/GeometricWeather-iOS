//
//  UIEffectView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/28.
//

import UIKit

private let touchUpAnimDuration = 0.45

private let touchDownAlpha = 0.2

class UIViewEffect : UIView {

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        self.alpha = touchDownAlpha
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
}

class UIStackViewEffect : UIStackView {

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        self.alpha = touchDownAlpha
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
}

class UILabelEffect : UILabel {

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        self.alpha = touchDownAlpha
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
}

class ImageButtonEffect: UIButton {

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        self.alpha = touchDownAlpha
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: touchUpAnimDuration) {
            self.alpha = 1.0
        }
    }
}

class AutoHideKeyboardTableView : UITableView {
    
    var hideKeyboardExecutor: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.hideKeyboardExecutor?()
    }
    
    override func touchesShouldBegin(
        _ touches: Set<UITouch>,
        with event: UIEvent?,
        in view: UIView
    ) -> Bool {
        self.hideKeyboardExecutor?()
        return super.touchesShouldBegin(touches, with: event, in: view)
    }
}
