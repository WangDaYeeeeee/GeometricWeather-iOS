//
//  MainNavigationBarTitleView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/4.
//

import UIKit
import GeometricWeatherBasic

private let iconSize = 14.0

class MainNavigationBarTitleView: UIView {
    
    // MARK: - subviews.
    
    private let progressView = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel(frame: .zero)
    private let currentPositionIcon = UIImageView(
        image: UIImage(systemName: "location.fill")
    )
    
    // MARK: - properties.
    
    var loading: Bool {
        get {
            return self.progressView.isAnimating
        }
        set {
            if self.progressView.isAnimating == newValue {
                return
            }
            if newValue {
                self.progressView.startAnimating()
            } else {
                self.progressView.stopAnimating()
            }
        }
    }
    var title: String {
        get {
            return self.titleLabel.text ?? ""
        }
        set {
            if self.titleLabel.text == newValue {
                return
            }
            self.titleLabel.text = newValue
        }
    }
    var showCurrentPositionIcon: Bool {
        get {
            return !self.currentPositionIcon.isHidden
        }
        set {
            if self.currentPositionIcon.isHidden != newValue {
                return
            }
            self.currentPositionIcon.isHidden = !newValue
        }
    }
    override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            super.tintColor = newValue
            
            self.progressView.color = newValue
            self.titleLabel.textColor = newValue
            self.currentPositionIcon.tintColor = newValue
        }
    }
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.font = titleFont
        
        self.addSubview(self.progressView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.currentPositionIcon)
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.progressView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.lessThanOrEqualToSuperview().offset(littleMargin)
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-8.0)
        }
        self.currentPositionIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(8.0)
            make.trailing.lessThanOrEqualToSuperview().offset(-littleMargin)
            make.size.equalTo(iconSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
