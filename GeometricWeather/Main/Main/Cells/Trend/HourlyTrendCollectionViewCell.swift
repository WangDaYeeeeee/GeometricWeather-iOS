//
//  HourlyTrendCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherBasic

// MARK: - cell.

class HourlyTrendCollectionViewCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
    private let trendView = PolylineAndHistogramView(frame: .zero)
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .label
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.contentView.addSubview(self.hourLabel)
        
        self.hourlyIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.hourlyIcon)
        
        self.contentView.addSubview(self.trendView)
        
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.hourlyIcon.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.hourlyIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.trendView.snp.makeConstraints { make in
            make.top.equalTo(self.hourlyIcon.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        prev: Hourly?,
        hourly: Hourly,
        next: Hourly?,
        temperatureRange: TemperatureRange,
        weatherCode: WeatherCode,
        timezone: TimeZone,
        showPrecipitationProb: Bool
    ) {
        self.hourLabel.text = getHourText(
            hour: hourly.getHour(
                isTwelveHour(),
                timezone: timezone
            )
        )
        
        self.hourlyIcon.image = UIImage.getWeatherIcon(
            weatherCode: hourly.weatherCode,
            daylight: hourly.daylight
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        
        self.trendView.highPolylineTrend = (
            start: prev == nil ? nil : getY(
                value: Double(
                    (prev?.temperature.temperature ?? 0) + hourly.temperature.temperature
                ) / 2.0,
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            ),
            center: getY(
                value: Double(hourly.temperature.temperature),
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            ),
            end: next == nil ? nil : getY(
                value: Double(
                    (next?.temperature.temperature ?? 0) + hourly.temperature.temperature
                ) / 2.0,
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            )
        )
        if showPrecipitationProb {
            let precipitationProb = hourly.precipitationProbability ?? 0.0
            if precipitationProb > 0 {
                self.trendView.histogramValue = precipitationProb / 100.0
                self.trendView.histogramDescription = getPercentText(
                    precipitationProb,
                    decimal: 0
                )
            } else {
                self.trendView.histogramValue = nil
            }
        } else {
            let precipitation = hourly.precipitation.total ?? 0.0
            if precipitation > 0 {
                let unit = SettingsManager.shared.precipitationUnit
                
                self.trendView.histogramValue = precipitation / 50.0 // 50 mm/h - heavy rain.
                self.trendView.histogramDescription = unit.formatValueWithUnit(
                    precipitation,
                    unit: ""
                )
            } else {
                self.trendView.histogramValue = nil
            }
        }
        
        let themeColors = ThemeManager.shared.weatherThemeDelegate.getThemeColors(
            weatherKind: weatherCodeToWeatherKind(code: weatherCode),
            daylight: ThemeManager.shared.daylight.value,
            lightTheme: self.traitCollection.userInterfaceStyle == .light
        )
        self.trendView.highPolylineColor = themeColors.daytime
        self.trendView.lowPolylineColor = themeColors.nighttime
        self.trendView.histogramColor = themeColors.daytime
        self.trendView.histogramLabel.textColor = precipitationProbabilityColor
        
        let tempUnit = SettingsManager.shared.temperatureUnit
        self.trendView.highPolylineDescription = tempUnit.formatValueWithUnit(
            hourly.temperature.temperature,
            unit: "°"
        )
    }
    
    // MARK: - cell selection.
    
    override var isHighlighted: Bool {
        didSet {
            if (self.isHighlighted) {
                self.contentView.layer.removeAllAnimations()
                self.contentView.alpha = 0.5
            } else {
                self.contentView.layer.removeAllAnimations()
                UIView.animate(
                    withDuration: 0.45,
                    delay: 0.0,
                    options: [.allowUserInteraction, .beginFromCurrentState]
                ) {
                    self.contentView.alpha = 1.0
                } completion: { _ in
                    // do nothing.
                }
            }
        }
    }
}

// MARK: - background.

class HourlyTrendCellBackgroundView: UIView {
    
    // MARK: - background subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    
    private let horizontalLinesView = HorizontalLinesBackgroundView(frame: .zero)
    
    // MARK: - background life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.hourLabel.text = "A"
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .clear
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.addSubview(self.hourLabel)
        
        self.addSubview(self.horizontalLinesView)
        
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.horizontalLinesView.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(littleMargin + mainTrendIconSize)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        weather: Weather,
        temperatureRange: TemperatureRange
    ) {
        guard let yesterday = weather.yesterday,
              let daytimeTemp = yesterday.daytimeTemperature,
              let nighttimeTemp = yesterday.nighttimeTemperature else {
            self.horizontalLinesView.highValue = nil
            self.horizontalLinesView.lowValue = nil
            return
        }
        
        self.horizontalLinesView.highValue = getY(
            value: Double(daytimeTemp),
            min: Double(temperatureRange.min),
            max: Double(temperatureRange.max)
        )
        self.horizontalLinesView.lowValue = getY(
            value: Double(nighttimeTemp),
            min: Double(temperatureRange.min),
            max: Double(temperatureRange.max)
        )
        
        self.horizontalLinesView.highLineColor = .separator
        self.horizontalLinesView.lowLineColor = .separator
        
        self.horizontalLinesView.highDescription = (
            SettingsManager.shared.temperatureUnit.formatValueWithUnit(daytimeTemp, unit: "°"),
            NSLocalizedString("yesterday", comment: "")
        )
        self.horizontalLinesView.lowDescription = (
            SettingsManager.shared.temperatureUnit.formatValueWithUnit(nighttimeTemp, unit: "°"),
            NSLocalizedString("yesterday", comment: "")
        )
    }
}

