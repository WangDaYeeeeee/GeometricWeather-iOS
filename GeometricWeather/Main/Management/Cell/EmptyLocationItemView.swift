//
//  EmptyLocationItemView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/4/27.
//

import Foundation
import UIKit
import GeometricWeatherBasic

class EmptyLocationItemView: UIView {
    
    private let titleLabel1 = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    private let sourceLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.titleLabel1.font = largeTitleFont
        self.titleLabel1.textColor = .label
        self.titleLabel1.numberOfLines = 1
        self.addSubview(self.titleLabel1)
        
        self.subtitleLabel.font = miniCaptionFont
        self.subtitleLabel.textColor = .tertiaryLabel
        self.subtitleLabel.numberOfLines = 1
        self.addSubview(self.subtitleLabel)
        
        self.sourceLabel.font = .systemFont(ofSize: miniCaptionFont.pointSize, weight: .bold)
        self.sourceLabel.textColor = .systemBlue
        self.sourceLabel.numberOfLines = 1
        self.addSubview(self.sourceLabel)
        
        self.titleLabel1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.top.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
        }
        self.sourceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalTo(self.sourceLabel.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location) {
        self.titleLabel1.text = getLocationText(location: location)
        self.subtitleLabel.text = location.toString()
        self.sourceLabel.text = "Powered by \(location.weatherSource.url)"
        self.sourceLabel.textColor = UIColor.colorFromRGB(location.weatherSource.color)
    }
}
