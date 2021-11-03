//
//  HomeViewController+PageIndicator.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/8.
//

import Foundation

private let showIndicatorDuration = 0.35
private let hideIndicatorDuration = 0.6
private let hideIndicatorDelay = 1.0

private var animationStatusKey = 100

private enum AnimationStatus: Int {
    case hiding
    case executingShowAnimation
    case showing
    case executingHideAnimation
}

extension HomeViewController {
    
    // true:   executing show animation.
    // false:  executing hide animation.
    // nil: no animation.
    private var animationStatus: AnimationStatus {
        set {
            objc_setAssociatedObject(
                self,
                &animationStatusKey,
                newValue.rawValue,
                .OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
        get {
            return AnimationStatus(
                rawValue: objc_getAssociatedObject(
                    self,
                    &animationStatusKey
                ) as? Int ?? AnimationStatus.hiding.rawValue
            ) ?? .hiding
        }
    }
    
    func showPageIndicator() {
        self.cancelDelayHideAnimation()
        
        if self.animationStatus == .hiding
            || self.animationStatus == .executingHideAnimation {
            self.executeShowAnimation()
        }
    }
    
    func delayHidePageIndicator() {
        self.cancelDelayHideAnimation()
        
        if self.animationStatus == .showing
            || self.animationStatus == .executingShowAnimation {
            self.delayExecuteHideAnimation()
        }
    }
    
    private func executeShowAnimation() {
        self.animationStatus = .executingShowAnimation
        
        self.indicator.layer.removeAllAnimations()
        
        UIView.animate(withDuration: showIndicatorDuration) {
            self.indicator.alpha = 1
        } completion: { [weak self] completed in
            if completed {
                self?.animationStatus = .showing
            }
        }

    }
    
    private func delayExecuteHideAnimation() {
        let timer = Timer(
            timeInterval: hideIndicatorDelay,
            repeats: false
        ) { [weak self] _ in
            self?.cancelDelayHideAnimation()
            
            self?.animationStatus = .executingHideAnimation
            
            self?.indicator.layer.removeAllAnimations()
            
            UIView.animate(withDuration: hideIndicatorDuration) {
                self?.indicator.alpha = 0
            } completion: { completed in
                if completed {
                    self?.animationStatus = .hiding
                }
            }

        }
        timer.fireDate = Date(timeIntervalSinceNow: hideIndicatorDelay)
        RunLoop.current.add(timer, forMode: .common)
        
        self.hideIndicatorTimer = timer
    }
    
    private func cancelDelayHideAnimation() {
        self.hideIndicatorTimer?.invalidate()
        self.hideIndicatorTimer = nil
    }
}
