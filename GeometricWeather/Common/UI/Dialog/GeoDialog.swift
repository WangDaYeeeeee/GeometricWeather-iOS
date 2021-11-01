//
//  GeoDialog.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/18.
//

import UIKit
import GeometricWeatherBasic

private let dragUpRatio = 0.3

private let showDuration = 0.6
private let hideDuration = 0.4
private let resetAnimationDuration = 0.4

private let initScale = 1.1
private let initOffset = 72.0

private enum DialogStatus {
    case hiding
    case executingShowAnimation
    case showing
    case executingHideAnimation
}

class GeoDialog: UIView {
        
    private let background = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialDark)
    )
    private var foreground = UIView(frame: .zero)
    
    private var status = DialogStatus.hiding
    private var dragging = false
    
    private var offsetY: CGFloat = 0
    private var offsetTrigger: CGFloat = 56.0
    
    private var foregroundAnimation: UIViewPropertyAnimator?
    private var backgroundAnimation: UIViewPropertyAnimator?
    
    // MARK: - life cycle.
    
    init(_ content: UIView) {
        super.init(frame: .zero)
        
        self.addSubview(self.background)
        self.addSubview(self.foreground)
        
        self.background.alpha = 0.0
        self.background.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.onTap)
            )
        )
        self.background.addGestureRecognizer(
            UIPanGestureRecognizer(
                target: self,
                action: #selector(self.onDrag(gesture:))
            )
        )
        
        self.foreground.alpha = 0.0
        self.foreground.transform = CGAffineTransform(
            translationX: 0.0,
            y: initOffset
        ).concatenating(
            CGAffineTransform(scaleX: initScale, y: initScale)
        )
        self.foreground.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.onTap)
            )
        )
        self.foreground.addGestureRecognizer(
            UIPanGestureRecognizer(
                target: self,
                action: #selector(self.onDrag(gesture:))
            )
        )
        
        content.layer.cornerRadius = cardRadius
        content.clipsToBounds = true
        content.backgroundColor = .systemBackground
        self.foreground.addSubview(content)
        
        self.background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.foreground.snp.makeConstraints { make in
            make.top.equalTo(
                self.safeAreaLayoutGuide.snp.top
            ).offset(littleMargin)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalTo(
                self.safeAreaLayoutGuide.snp.bottom
            ).offset(-littleMargin)
        }
        content.snp.makeConstraints{ make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.width.equalTo(getTabletAdaptiveWidth())
            make.height.lessThanOrEqualToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        ThemeManager.shared.globalOverrideUIStyle.syncAddObserver(
            self
        ) { [weak self] newValue in
            self?.overrideUserInterfaceStyle = newValue
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        ThemeManager.shared.globalOverrideUIStyle.removeObserver(self)
    }
    
    // MARK: - action.
    
    @objc private func onTap() {
        self.dismiss()
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
            self.dragging = false
            break
        }
    }
    
    private func beginDrag() {
        self.status = .showing
        self.dragging = true
        
        self.clearAnimations(onlyForeground: true)
        self.offsetY = self.foreground.transform.ty
    }
    
    private func dragContentView(_ gesture: UIPanGestureRecognizer) {
        let offset = gesture.translation(in: self).y * (
            self.offsetY > 0 ? 1 : dragUpRatio
        )
        
        if self.dragging {
            self.offsetY += offset
        } else {
            self.offsetY = 0
        }
        
        if self.offsetY > 0 {
            self.foreground.alpha = 1.0 - min(
                1.0,
                abs(self.offsetY) / self.offsetTrigger
            )
        } else {
            self.foreground.alpha = 1.0
        }
        self.foreground.transform = self.foreground.transform.translatedBy(
            x: 0,
            y: offset
        )
        
        gesture.setTranslation(.zero, in: self)
    }
    
    private func endDrag() {
        if !self.dragging {
            return
        }
        self.dragging = false
        
        if self.offsetY >= self.offsetTrigger {
            self.dismiss()
        } else {
            self.resetSelf()
        }
    }
    
    private func resetSelf() {
        let a = UIViewPropertyAnimator(
            duration: resetAnimationDuration,
            dampingRatio: 0.5
        ) { [weak self] in
            self?.background.alpha = 1.0
            
            self?.foreground.alpha = 1.0
            self?.foreground.transform = CGAffineTransform(
                translationX: 0,
                y: 0
            ).concatenating(
                CGAffineTransform(scaleX: 1.0, y: 1.0)
            )
        }
        a.addCompletion { [weak self] position in
            if position == .end {
                self?.offsetY = 0
            }
        }
        a.startAnimation()
        
        self.foregroundAnimation = a
    }
    
    private func getProgress() -> Double {
        return -1 * self.offsetY / self.offsetTrigger
    }
    
    private func getAlpha() -> Double {
        return 1.0 - min(
            fabs(self.getProgress()),
            1.0
        )
    }
    
    // MARK: - interfaces.
    
    func showOn(_ superView: UIView) {
        if (
            self.status == .showing
            || self.status == .executingShowAnimation
        ) && superView == self.superview {
            return
        }
        
        self.clearAnimations()
        self.removeFromSuperview()
        
        superView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.status = .executingShowAnimation
        
        let backgroundAnim = UIViewPropertyAnimator(
            duration: showDuration * 0.5,
            curve: .easeInOut
        ) {
            self.background.alpha = 1.0
        }
    
        let foregroundAnim = UIViewPropertyAnimator(
            duration: showDuration,
            dampingRatio: 0.6
        ) {
            self.foreground.alpha = 1.0
            self.foreground.transform = CGAffineTransform(
                translationX: 0,
                y: 0
            ).concatenating(
                CGAffineTransform(scaleX: 1, y: 1)
            )
        }
        foregroundAnim.addCompletion { position in
            if position == .end {
                self.status = .showing
            }
        }
        
        backgroundAnim.startAnimation()
        foregroundAnim.startAnimation()
        self.backgroundAnimation = backgroundAnim
        self.foregroundAnimation = foregroundAnim
    }
    
    func dismiss() {
        if self.status == .hiding
            || self.status == .executingHideAnimation {
            return
        }
        
        self.clearAnimations()
        
        let backgroundAnim = UIViewPropertyAnimator(
            duration: hideDuration,
            curve: .easeInOut
        ) {
            self.background.alpha = 0.0
        }
        backgroundAnim.addCompletion { position in
            if position == .end {
                self.status = .hiding
                self.removeFromSuperview()
            }
        }
    
        let foregroundAnim = UIViewPropertyAnimator(
            duration: hideDuration * 0.5,
            curve: .easeInOut
        ) {
            self.foreground.alpha = 0.0
            self.foreground.transform = CGAffineTransform(
                translationX: 0,
                y: initOffset
            )
        }
        
        backgroundAnim.startAnimation()
        foregroundAnim.startAnimation()
        self.backgroundAnimation = backgroundAnim
        self.foregroundAnimation = foregroundAnim
    }
    
    private func clearAnimations(onlyForeground: Bool = false) {
        self.foregroundAnimation?.stopAnimation(true)
        self.foregroundAnimation = nil
        if onlyForeground {
            return
        }
        
        self.backgroundAnimation?.stopAnimation(true)
        self.backgroundAnimation = nil
    }
}
