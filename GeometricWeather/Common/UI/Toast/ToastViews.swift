//
//  ToastViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import UIKit
import GeometricWeatherBasic

// MARK: - ext.

let shortToastInerval = 1.5
let longToastInterval = 3.0

extension UIView {
    
    func showToastMessage(
        _ message: String,
        WithAction action: String? = nil,
        andCallback callback: (() -> Void)? = nil,
        withDuration duration: TimeInterval = shortToastInerval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        self.showToastView(
            action != nil && callback != nil ? ActionableToastView(
                message: message,
                action: action!,
                actionCallback: callback!
            ) : MessageToastView(
                message: message
            ),
            withDuration: duration,
            completion: completion
        )
    }
    
    func showToastView(
        _ toast: UIView,
        withDuration duration: TimeInterval = shortToastInerval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        self.showToast(
            ToastWrapperView(toast: toast),
            duration: duration,
            completion: completion
        )
    }
}

// MARK: - toast view.

class ToastWrapperView: UIView {
    
    private let toast: UIView
    
    init(toast: UIView) {
        self.toast = toast
        super.init(frame: .zero)
        self.backgroundColor = .clear
        
        self.addSubview(self.toast)
        self.toast.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.height.greaterThanOrEqualTo(64.0)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        self.messageLabel.text = message
        self.messageLabel.font = titleFont
        self.messageLabel.textColor = .label
        self.messageLabel.textAlignment = .center
        self.messageLabel.numberOfLines = 0
        self.messageLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.messageLabel)
        
        self.messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
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
        self.actionButton.layer.shadowColor = UIColor.systemBlue.cgColor
        self.actionButton.layer.cornerRadius = 6.0
        self.actionButton.layer.shadowOpacity = 0.3
        self.actionButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
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
            make.leading.equalToSuperview().offset(littleMargin)
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
        
        if let wrapper = self.superview {
            wrapper.superview?.hideToast(wrapper, fromTap: true)
        }
    }
}
