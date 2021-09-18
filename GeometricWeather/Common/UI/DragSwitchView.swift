//
//  DragSwitchView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/6.
//

import UIKit
import GeometricWeatherBasic

private let dragRatio = 0.4
private let triggerRatio = 1.0 / 3.0 * dragRatio

private let resetAnimationDuration = 0.8

protocol DragSwitchDelegate: AnyObject {
    
    func onSwiped(_ progress: Double)
    func onSwitched(_ indexOffset: Int)
}

class DragSwitchView: UIView {
    
    // MARK: - properties.
    
    // subview.
    
    let contentView = UIView(frame: .zero)
    
    // offset controll.
    
    private var offsetX: CGFloat = 0 {
        didSet {
            self.delegate?.onSwiped(getProgress())
        }
    }
    private var offsetTrigger: CGFloat = 100
    private var initCenter: CGPoint = .zero
    
    // delegate.
    
    weak var delegate: DragSwitchDelegate?
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        self.addSubview(self.contentView)
        
        self.addGestureRecognizer(
            UIPanGestureRecognizer(
                target: self,
                action: #selector(self.onDrag(gesture:))
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - layout.
    
    override func layoutSubviews() {
        self.offsetTrigger = getTabletAdaptiveWidth(
            maxWidth: self.frame.width
        ) * triggerRatio
        self.initCenter = CGPoint(
            x: self.frame.width / 2,
            y: self.frame.height / 2
        )
        
        self.contentView.frame = CGRect(
            x: self.offsetX,
            y: 0,
            width: self.frame.width,
            height: self.frame.height
        )
    }
    
    // MARK: - gesture.
    
    override func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        let translation = gesture.translation(in: self)
        return abs(translation.x) > abs(translation.y)
    }
    
    @objc private func onDrag(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            if gesture.state == .began {
                self.beginDrag()
            }
            self.dragContentView(gesture)
            break
            
        case .ended, .cancelled, .failed:
            self.dragContentView(gesture)
            self.endDrag()
            break
            
        default:
            // do nothing.
            break
        }
    }
    
    private func beginDrag() {
        self.contentView.layer.removeAllAnimations()
        self.offsetX = self.center.x - self.initCenter.x
    }
    
    private func dragContentView(_ gesture: UIPanGestureRecognizer) {
        self.dragContentView(
            gesture.translation(in: self).x * dragRatio
        )
        gesture.setTranslation(.zero, in: self)
    }
    
    private func dragContentView(_ offsetX: Double) {
        self.offsetX += offsetX
        
        self.contentView.center = CGPoint(
            x: self.initCenter.x + self.offsetX,
            y: self.initCenter.y
        )
        self.contentView.alpha = self.getAlpha()
    }
    
    private func endDrag() {
        if abs(self.offsetX) >= self.offsetTrigger {
            self.delegate?.onSwitched(self.offsetX > 0 ? -1 : 1)
            
            self.offsetX = 0
            self.contentView.center = self.initCenter
            self.contentView.alpha = 1
        } else {
            self.resetSelf()
        }
    }
    
    private func resetSelf() {
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
        
        Self.animate(withDuration: resetAnimationDuration, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.8, options: options , animations: { [weak self] in
            guard self != nil else {
                return
            }
            
            self!.contentView.center = CGPoint(
                x: self!.frame.width / 2,
                y: self!.frame.height / 2
            )
            self!.contentView.alpha = 1
        }, completion: { [weak self] finished in
            if finished {
                self?.offsetX = 0
            }
        })
    }
    
    private func getProgress() -> Double {
        return -1 * self.offsetX / self.offsetTrigger
    }
    
    private func getAlpha() -> Double {
        return 1.0 - min(
            fabs(self.getProgress()),
            1.0
        )
    }
}
