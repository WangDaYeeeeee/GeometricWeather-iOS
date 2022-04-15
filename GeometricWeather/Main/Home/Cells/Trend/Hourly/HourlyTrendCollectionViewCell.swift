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
    private let dateLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
    private let trendView = HistogramView(frame: .zero)
    
    // MARK: - inner data.
    
    private var weatherCode: WeatherCode?
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .label
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.contentView.addSubview(self.hourLabel)
        
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .secondaryLabel
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.contentView.addSubview(self.dateLabel)
        
        self.hourlyIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.hourlyIcon)
        
        self.contentView.addSubview(self.trendView)
        
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.hourlyIcon.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin)
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
        
        ThemeManager.shared.daylight.addNonStickyObserver(self) { daylight in
            if self.weatherCode == nil {
                return
            }
            
            self.updateTrendColors(
                weatherCode: self.weatherCode ?? .clear,
                daylight: daylight
            )
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        hourly: Hourly,
        temperatureRange: ClosedRange<Int>,
        weatherCode: WeatherCode,
        timezone: TimeZone,
        histogramType: HourlyPrecipitationHistogramType
    ) {
        self.weatherCode = weatherCode
        
        self.hourLabel.text = getHourText(
            hour: hourly.getHour(
                isTwelveHour(),
                timezone: timezone
            )
        )
        
        self.dateLabel.text = hourly.formatDate(
            format: NSLocalizedString("date_format_short", comment: "")
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
        
        self.trendView.highValue = getY(
            value: Double(hourly.temperature.temperature),
            min: Double(temperatureRange.lowerBound),
            max: Double(temperatureRange.upperBound)
        )
        self.trendView.lowValue = nil
        
        switch histogramType {
        case .precipitationProb:
            let precipitationProb = hourly.precipitationProbability ?? 0.0
            if precipitationProb > 0 {
                self.trendView.bottomDescription = (
                    getPercentText(
                        precipitationProb,
                        decimal: 0
                    ),
                    ""
                )
            } else {
                self.trendView.bottomDescription = nil
            }
            
        case .precipitationIntensity:
            let precipitationIntensity = hourly.precipitationIntensity ?? 0.0
            if precipitationIntensity > 0 {
                let unit = SettingsManager.shared.precipitationIntensityUnit
                
                self.trendView.bottomDescription = (
                    unit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: ""
                    ),
                    ""
                )
            } else {
                self.trendView.bottomDescription = nil
            }
            
        case .none:
            self.trendView.bottomDescription = nil
        }
        
        self.updateTrendColors(
            weatherCode: weatherCode,
            daylight: ThemeManager.shared.daylight.value
        )
        
        let tempUnit = SettingsManager.shared.temperatureUnit
        self.trendView.highDescription = (
            tempUnit.formatValueWithUnit(
                hourly.temperature.temperature,
                unit: ""
            ),
            "°"
        )
    }
    
    private func updateTrendColors(weatherCode: WeatherCode, daylight: Bool) {
        let themeColor = ThemeManager.shared.weatherThemeDelegate.getThemeColor(
            weatherKind: weatherCodeToWeatherKind(code: weatherCode),
            daylight: daylight
        )
        self.trendView.color = themeColor
        self.trendView.bottomLabel.textColor = precipitationProbabilityColor
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
        temperatureRange: ClosedRange<Int>
    ) {
        guard
            let yesterday = weather.yesterday,
            let daytimeTemp = yesterday.daytimeTemperature,
            let nighttimeTemp = yesterday.nighttimeTemperature
        else {
            self.horizontalLinesView.highValue = nil
            self.horizontalLinesView.lowValue = nil
            return
        }
        
        self.horizontalLinesView.highValue = getY(
            value: Double(daytimeTemp),
            min: Double(temperatureRange.lowerBound),
            max: Double(temperatureRange.upperBound)
        )
        self.horizontalLinesView.lowValue = getY(
            value: Double(nighttimeTemp),
            min: Double(temperatureRange.lowerBound),
            max: Double(temperatureRange.upperBound)
        )
        
        self.horizontalLinesView.highLineColor = .gray
        self.horizontalLinesView.lowLineColor = .gray
        
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
