//
//  AbstractMainCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

private let blurStyle = UIBlurEffect.Style.prominent

protocol AbstractMainItem {
    
    func bindData(location: Location)
}

class MainTableViewCell: UITableViewCell, AbstractMainItem {
    
    let cardContainer = UIVisualEffectView(
        effect: UIBlurEffect(style: blurStyle)
    )
    
    let titleVibrancyContainer = UIVisualEffectView(
        effect: UIVibrancyEffect(
            blurEffect: UIBlurEffect(style: blurStyle)
        )
    )
    let cardTitle = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.cardContainer.layer.cornerRadius = cardRadius
        self.cardContainer.layer.masksToBounds = true
        self.contentView.addSubview(self.cardContainer)
        
        self.cardTitle.font = titleFont
        self.titleVibrancyContainer.contentView.addSubview(self.cardTitle)
        self.cardContainer.contentView.addSubview(self.titleVibrancyContainer)

        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(littleMargin)
            make.trailing.equalToSuperview().offset(-littleMargin)
            make.bottom.equalToSuperview()
        }
        self.cardContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.width.equalTo(getTabletAdaptiveWidth())
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.cardTitle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location) {
        self.cardContainer.contentView.backgroundColor = UIColor { trait in
            return .systemBackground.withAlphaComponent(
                trait.userInterfaceStyle == .light ? 0.1 : 0.0
            )
        }
    }
}
