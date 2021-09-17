//
//  MainDetailItemView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/22.
//

import UIKit

private let iconSize = 24.0

class MainDetailItemView: UIView {
    
    // MARK: - properties.
    
    private let icon = UIImageView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let bodyLabel = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        self.icon.tintColor = .label
        self.icon.contentMode = .scaleAspectFit
        self.addSubview(self.icon)
        
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.titleLabel.numberOfLines = 1
        self.addSubview(self.titleLabel)
        
        self.bodyLabel.font = captionFont
        self.bodyLabel.textColor = .secondaryLabel
        self.bodyLabel.numberOfLines = 0
        self.bodyLabel.lineBreakMode = .byWordWrapping
        self.addSubview(self.bodyLabel)
        
        self.icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.size.equalTo(iconSize)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.icon.snp.trailing).offset(littleMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.centerY.equalTo(self.icon.snp.centerY)
        }
        self.bodyLabel.snp.makeConstraints{ make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalTo(self.titleLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - interfaces.
    
    func bindData(iconName: String, title: String, body: String) {
        self.icon.image = UIImage(
            systemName: iconName
        )
        self.titleLabel.text = title
        self.bodyLabel.text = body
    }
}
