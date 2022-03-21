//
//  AlertTableViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import Foundation
import GeometricWeatherBasic

class AlertTableViewCell: UITableViewCell {
    
    // MARK: - subviews.
    
    private let titleLabel = UILabel(frame: .zero)
    private let captionLabel = UILabel(frame: .zero)
    private let bodyLabel = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.titleLabel.font = titleFont
        self.titleLabel.textColor = .label
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.titleLabel)
        
        self.captionLabel.font = miniCaptionFont
        self.captionLabel.textColor = .tertiaryLabel
        self.captionLabel.numberOfLines = 0
        self.captionLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.captionLabel)
        
        self.bodyLabel.font = bodyFont
        self.bodyLabel.textColor = .secondaryLabel
        self.bodyLabel.numberOfLines = 0
        self.bodyLabel.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(self.bodyLabel)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.captionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(self.captionLabel.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(_ alert: WeatherAlert) {
        self.titleLabel.text = alert.description
        
        let format = DateFormatter()
        format.dateStyle = .long
        format.timeStyle = .short
        self.captionLabel.text = format.string(
            from: Date(timeIntervalSince1970: alert.time)
        )
        
        self.bodyLabel.text = alert.content
    }
}
