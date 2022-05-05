//
//  MainHeaderCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import SnapKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let minCountAnimationDuration = 2.0
private let unitCountAnimationDeltaTemperature = 10.0

class MainTableViewHeaderView: UIView, AbstractMainItem {
    
    private let container = UIView(frame: .zero)
    private let largeTemperature = UICountingLabel(frame: .zero)
    private let title = UILabel(frame: .zero)
    private let subtitle = UILabel(frame: .zero)
    
    private var currentTemperature = 0
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.container)
        
        self.largeTemperature.textAlignment = .natural
        self.largeTemperature.font = designTitleFont
        self.largeTemperature.textColor = .white
        self.largeTemperature.format = "%d°"
        self.largeTemperature.method = .easeInOut
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
    
    func bindData(location: Location, timeBar: MainTimeBarView?) {
        if let weather = location.weather {
            let previousTemperature = self.currentTemperature
            self.currentTemperature = SettingsManager.shared.temperatureUnit.getValue(
                weather.current.temperature.temperature
            )
            self.largeTemperature.count(
                from: CGFloat(previousTemperature),
                to: CGFloat(self.currentTemperature),
                withDuration: min(
                    minCountAnimationDuration,
                    Double(
                        abs(previousTemperature - self.currentTemperature)
                    ) / unitCountAnimationDeltaTemperature
                )
            )
            
            var description = weather.current.weatherText
            if let realFeelTemperature = weather.current.temperature.realFeelTemperature {
                description = description
                + ", "
                + getLocalizedText("feels_like")
                + " "
                + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    realFeelTemperature,
                    unit: getLocalizedText("temperature_unit_short_c")
                )
            }
            self.title.text = description
            
            self.subtitle.text = weather.current.airQuality.isValid() ? (
                getLocalizedText(
                    "air_quality"
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
