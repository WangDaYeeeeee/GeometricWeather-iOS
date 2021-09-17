//
//  MainHeaderCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import SnapKit

class MainTableViewHeaderView: UIView, AbstractMainItem {
    
    private let container = UIView(frame: .zero)
    private let largeTemperature = UILabel(frame: .zero)
    private let title = UILabel(frame: .zero)
    private let subtitle = UILabel(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.container)
        
        self.largeTemperature.textAlignment = .natural
        self.largeTemperature.font = designTitleFont
        self.largeTemperature.textColor = .white
        self.container.addSubview(self.largeTemperature)
        
        self.title.textAlignment = .natural
        self.title.font = largeTitleFont
        self.title.textColor = .white
        self.container.addSubview(self.title)
        
        self.subtitle.textAlignment = .natural
        self.subtitle.font = titleFont
        self.subtitle.textColor = .white
        self.container.addSubview(self.subtitle)
        
        self.container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
            make.width.equalTo(getTabletAdaptiveWidth())
            make.centerX.equalToSuperview()
        }
        
        self.subtitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalTo(self.subtitle.snp.top)
        }
        self.largeTemperature.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
            make.bottom.equalTo(self.title.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(location: Location) {
        if let weather = location.weather {
            self.largeTemperature.text = SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                weather.current.temperature.temperature,
                unit: NSLocalizedString("temperature_unit_short_c", comment: "")
            )
            
            var description = weather.current.weatherText
            if let realFeelTemperature = weather.current.temperature.realFeelTemperature {
                description = description
                + ", "
                + NSLocalizedString("feels_like", comment: "")
                + " "
                + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    realFeelTemperature,
                    unit: NSLocalizedString("temperature_unit_short_c", comment: "")
                )
            }
            self.title.text = description
            
            self.subtitle.text = weather.current.airQuality.isValid() ? (
                NSLocalizedString(
                    "air_quality", comment: ""
                ) + " - " + getAirQualityText(
                    level: weather.current.airQuality.aqiLevel ?? 0
                )
            ) : getShortWindText(wind: weather.current.wind)
            
            self.largeTemperature.alpha = 1.0
            self.title.alpha = 1.0
            self.subtitle.alpha = 1.0
        } else {
            self.largeTemperature.alpha = 0.0
            self.title.alpha = 0.0
            self.subtitle.alpha = 0.0
        }
    }
}
