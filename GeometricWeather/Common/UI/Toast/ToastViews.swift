//
//  ToastViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import UIKit
import GeometricWeatherBasic

private let dragUpRatio = 0.1

private let showDuration = 1.0
private let hideDuration = 0.3
private let resetAnimationDuration = 0.4

private let initScale = 1.1
private let initOffset = 128.0

private enum ToastStatus {
    case hiding
    case executingShowAnimation
    case showing
    case executingHideAnimation
}

class ToastWrapperView: UIView {
    
    private let toast: UIView
    private let shadow: ResizeableShadowView
    
    private var status = ToastStatus.hiding
    private var dragging = false
    
    private var offsetY: CGFloat = 0
    private var offsetTrigger: CGFloat = 16.0
    
    private var animation: UIViewPropertyAnimator?
    
    private var dragBeginCallback: (() -> Void)?
    private var dragEndCallback: (() -> Void)?
    private var dragDismissCallback: (() -> Void)?
    
    init(toast: UIView) {
        self.toast = toast
        
        self.shadow = ResizeableShadowView(
            frame: .zero,
            shadow: Shadow(
                offset: CGSize(width: 0.0, height: 4.0),
                blur: 18.0,
                color: .black.withAlphaComponent(0.1)
            ),
            cornerRadius: ResizeableShadowView.capsuleRadius
        )
        
        super.init(frame: .zero)
        self.backgroundColor = .clear
        
        self.addSubview(self.shadow)
        self.addSubview(self.toast)
        
        self.shadow.snp.makeConstraints { make in
            make.edges.equalTo(self.toast)
        }
        self.toast.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.height.greaterThanOrEqualTo(64.0)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        
        self.alpha = 0.0
        self.transform = CGAffineTransform(
            translationX: 0.0,
            y: initOffset
        ).concatenating(
            CGAffineTransform(scaleX: initScale, y: initScale)
        )
        
        self.status = .hiding
        
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
        if self.status == .executingHideAnimation
            || self.status == .hiding {
            return
        }
        
        self.status = .showing
        self.dragging = true
        
        self.clearAnimations()
        self.offsetY = self.transform.ty
        
        self.dragBeginCallback?()
    }
    
    private func dragContentView(_ gesture: UIPanGestureRecognizer) {
        if self.status == .executingHideAnimation
            || self.status == .hiding {
            return
        }
        
        let offset = gesture.translation(in: self).y * (
            self.offsetY > 0 ? 1 : dragUpRatio
        )
        
        if self.dragging {
            self.offsetY += offset
        } else {
            self.offsetY = 0
        }
        
        self.transform = self.transform.translatedBy(
            x: 0,
            y: offset
        )
        
        gesture.setTranslation(.zero, in: self)
    }
    
    private func endDrag() {
        if self.status == .executingHideAnimation
            || self.status == .hiding {
            return
        }
        
        if !self.dragging {
            return
        }
        self.dragging = false
        
        if self.offsetY >= self.offsetTrigger {
            self.dragDismissCallback?()
        } else {
            self.resetSelf()
        }
        
        self.dragEndCallback?()
    }
    
    private func resetSelf() {
        let a = UIViewPropertyAnimator(
            duration: resetAnimationDuration,
            dampingRatio: 0.5
        ) { [weak self] in
            self?.alpha = 1.0
            self?.transform = CGAffineTransform(
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
        
        self.animation = a
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
    
    // MARK: - visibility.
    
    func executeShowAnimation(
        withCompletion completion: (() -> Void)?,
        dragBeginCallback beginCallback: (() -> Void)?,
        dragEndCallback endCallback: (() -> Void)?,
        andDragDismissCallback dismissCallback: (() -> Void)?
    ) {
        self.clearAnimations()
        
        self.dragBeginCallback = beginCallback
        self.dragEndCallback = endCallback
        self.dragDismissCallback = dismissCallback
        
        self.status = .executingShowAnimation
        
        let a = UIViewPropertyAnimator(
            duration: showDuration,
            dampingRatio: 0.5
        ) {
            self.alpha = 1.0
            self.transform = CGAffineTransform(
                translationX: 0,
                y: 0
            ).concatenating(
                CGAffineTransform(scaleX: 1, y: 1)
            )
        }
        a.addCompletion { [weak self] position in
            if position == .end {
                self?.status = .showing
                completion?()
            }
        }
        a.startAnimation()
        
        self.animation = a
    }
    
    func executeHideAnimation(
        withCompletion completion: (() -> Void)?
    ) {
        self.clearAnimations()
        
        self.status = .executingHideAnimation
        
        let a = UIViewPropertyAnimator(
            duration: hideDuration,
            curve: .easeInOut
        ) {
            self.alpha = 0.0
            self.transform = CGAffineTransform(
                translationX: 0,
                y: initOffset
            )
        }
        a.addCompletion { [weak self] position in
            if position == .end {
                self?.status = .hiding
                completion?()
            }
        }
        a.startAnimation()
        
        self.animation = a
    }
    
    private func clearAnimations() {
        self.animation?.stopAnimation(true)
        self.animation = nil
    }
}

class MessageToastView: UIVisualEffectView {
    
    // MARK: - subviews.
    
    private let messageLabel = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    init(
        message: String
    ) {
        super.init(
            effect: UIBlurEffect(style: .prominent)
        )
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.layer.cornerRadius = 24.0
        
        self.messageLabel.text = message
        self.messageLabel.font = titleFont
        self.messageLabel.textColor = .label
        self.messageLabel.textAlignment = .center
        self.messageLabel.numberOfLines = 0
        self.messageLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.messageLabel)
        
        self.messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = min(
            self.frame.width,
            self.frame.height
        ) / 2.0
        self.layer.masksToBounds = true
    }
}

class ActionableToastView: UIVisualEffectView {
    
    // MARK: - subviews.
    
    private let messageLabel = UILabel(frame: .zero)
    private let actionButton = CornerButton(frame: .zero)
    
    private let actionCallback: () -> Void
    
    // MARK: - life cycle.
    
    init(
        message: String,
        action: String,
        actionCallback: @escaping () -> Void
    ) {
        self.actionCallback = actionCallback
        super.init(
            effect: UIBlurEffect(style: .prominent)
        )
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.layer.cornerRadius = 24.0
        
        self.messageLabel.text = message
        self.messageLabel.font = titleFont
        self.messageLabel.textColor = .label
        self.messageLabel.numberOfLines = 0
        self.messageLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.messageLabel)
        
        self.actionButton.setTitle(action, for: .normal)
        self.actionButton.titleLabel?.font = titleFont
        self.actionButton.setTitleColor(.white, for: .normal)
        self.actionButton.backgroundColor = .systemBlue
        self.actionButton.addTarget(
            self,
            action: #selector(self.onAction),
            for: .touchUpInside
        )
        self.contentView.addSubview(self.actionButton)
        
        self.actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.centerY.equalToSuperview()
        }
        self.messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalTo(self.actionButton.snp.leading).offset(-littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = min(
            self.frame.width,
            self.frame.height
        ) / 2.0
        self.layer.masksToBounds = true
    }
    
    // MARK: - actions.
    
    @objc private func onAction() {
        self.actionCallback()
        
        if let wrapper = self.superview as? ToastWrapperView {
            wrapper.superview?.hideToast(wrapper, fromTap: true)
        }
    }
}
