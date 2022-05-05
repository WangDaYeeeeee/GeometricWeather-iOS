//
//  AbstractMainCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let blurStyle = UIBlurEffect.Style.prominent

protocol AbstractMainItem {
    
    func bindData(location: Location, timeBar: MainTimeBarView?)
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
    
    let backgroundShadowView = ResizeableShadowView(
        frame: .zero,
        shadow: Shadow(
            offset: CGSize(width: 0.0, height: 2.0),
            blur: 12.0,
            color: .black.withAlphaComponent(0.2)
        ),
        cornerRadius: cardRadius
    )
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        
        self.contentView.addSubview(self.backgroundShadowView)
        
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
        self.backgroundShadowView.snp.makeConstraints { make in
            make.edges.equalTo(self.cardContainer)
        }
        self.cardTitle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location, timeBar: MainTimeBarView?) {
        self.cardContainer.contentView.backgroundColor = UIColor(
            ThemeManager.shared.weatherThemeDelegate.getCardBackgroundColor(
                weatherKind: weatherCodeToWeatherKind(
                    code: location.weather?.current.weatherCode ?? .clear
                ),
                daylight: ThemeManager.shared.daylight.value
            )
        )
        
        if let timeBar = timeBar {
            timeBar.removeFromSuperview()
            self.cardContainer.contentView.addSubview(timeBar)
            
            if let weather = location.weather {
                timeBar.register(
                    weather: weather,
                    andTimezone: location.timezone
                )
            }
            
            timeBar.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            self.titleVibrancyContainer.snp.remakeConstraints { make in
                make.top.equalTo(timeBar.snp.bottom).offset(littleMargin)
                make.leading.equalToSuperview().offset(normalMargin)
                make.trailing.equalToSuperview().offset(-normalMargin)
            }
        } else {
            self.titleVibrancyContainer.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(normalMargin)
                make.leading.equalToSuperview().offset(normalMargin)
                make.trailing.equalToSuperview().offset(-normalMargin)
            }
        }
    }
}
