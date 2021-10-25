//
//  DailyTrendTableViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/14.
//

import UIKit
import GeometricWeatherBasic

enum DailyHistogramType {
    case precipitationProb
    case precipitationTotal
    case precipitationIntensity
    case none
}

// MARK: - cell.

class DailyTrendCollectionViewCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let daytimeIcon = UIImageView(frame: .zero)
    private let nighttimeIcon = UIImageView(frame: .zero)
    
    private let trendView = PolylineAndHistogramView(frame: .zero)
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.weekLabel.font = bodyFont
        self.weekLabel.textColor = .label
        self.weekLabel.textAlignment = .center
        self.weekLabel.numberOfLines = 1
        self.contentView.addSubview(self.weekLabel)
        
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .secondaryLabel
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.contentView.addSubview(self.dateLabel)
        
        self.daytimeIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.daytimeIcon)
        
        self.nighttimeIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.nighttimeIcon)
        
        self.contentView.addSubview(self.trendView)
        
        self.weekLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.weekLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.daytimeIcon.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.daytimeIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.nighttimeIcon.snp.makeConstraints { make in
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.daytimeIcon.snp.width)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.trendView.snp.makeConstraints { make in
            make.top.equalTo(self.daytimeIcon.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.nighttimeIcon.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        prev: Daily?,
        daily: Daily,
        next: Daily?,
        temperatureRange: TemperatureRange,
        weatherCode: WeatherCode,
        timezone: TimeZone,
        histogramType: DailyHistogramType
    ) {
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? NSLocalizedString("today", comment: "")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: NSLocalizedString("date_format_short", comment: "")
        )
        
        self.daytimeIcon.image = UIImage.getWeatherIcon(
            weatherCode: daily.day.weatherCode,
            daylight: true
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        self.nighttimeIcon.image = UIImage.getWeatherIcon(
            weatherCode: daily.night.weatherCode,
            daylight: false
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        
        self.trendView.highPolylineTrend = (
            start: prev == nil ? nil : getY(
                value: Double(
                    (prev?.day.temperature.temperature ?? 0) + daily.day.temperature.temperature
                ) / 2.0,
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            ),
            center: getY(
                value: Double(daily.day.temperature.temperature),
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            ),
            end: next == nil ? nil : getY(
                value: Double(
                    (next?.day.temperature.temperature ?? 0) + daily.day.temperature.temperature
                ) / 2.0,
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            )
        )
        self.trendView.lowPolylineTrend = (
            start: prev == nil ? nil : getY(
                value: Double(
                    (prev?.night.temperature.temperature ?? 0) + daily.night.temperature.temperature
                ) / 2.0,
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            ),
            center: getY(
                value: Double(daily.night.temperature.temperature),
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            ),
            end: next == nil ? nil : getY(
                value: Double(
                    (next?.night.temperature.temperature ?? 0) + daily.night.temperature.temperature
                ) / 2.0,
                min: Double(temperatureRange.min),
                max: Double(temperatureRange.max)
            )
        )
        
        switch histogramType {
        case .precipitationProb:
            let precipitationProb = max(
                daily.day.precipitationProbability ?? 0.0,
                daily.night.precipitationProbability ?? 0.0
            )
            if precipitationProb > 0 {
                self.trendView.histogramValue = min(precipitationProb / 100.0, 1.0)
                self.trendView.histogramDescription = getPercentText(
                    precipitationProb,
                    decimal: 0
                )
            } else {
                self.trendView.histogramValue = nil
            }
            
        case .precipitationTotal:
            let precipitationTotal = max(
                daily.day.precipitationTotal ?? 0.0,
                daily.night.precipitationTotal ?? 0.0
            )
            if precipitationTotal > 0 {
                let unit = SettingsManager.shared.precipitationUnit
                
                self.trendView.histogramValue = min(precipitationTotal / 50.0, 1.0) // 50 mm/d - heavy rain.
                self.trendView.histogramDescription = unit.formatValueWithUnit(
                    precipitationTotal,
                    unit: ""
                )
            } else {
                self.trendView.histogramValue = nil
            }
            
        case .precipitationIntensity:
            let precipitationIntensity = max(
                daily.day.precipitationIntensity ?? 0.0,
                daily.night.precipitationIntensity ?? 0.0
            )
            if precipitationIntensity > 0 {
                let unit = SettingsManager.shared.precipitationIntensityUnit
                
                self.trendView.histogramValue = min(precipitationIntensity / 11.33, 1.0) // 11.33 mm/h - heavy rain.
                self.trendView.histogramDescription = unit.formatValueWithUnit(
                    precipitationIntensity,
                    unit: ""
                )
            } else {
                self.trendView.histogramValue = nil
            }
            
        case .none:
            self.trendView.histogramValue = nil
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
            daily.day.temperature.temperature,
            unit: "°"
        )
        self.trendView.lowPolylineDescription = tempUnit.formatValueWithUnit(
            daily.night.temperature.temperature,
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

class DailyTrendCellBackgroundView: UIView {
    
    // MARK: - background subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let horizontalLinesView = HorizontalLinesBackgroundView(frame: .zero)
    
    // MARK: - background life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.weekLabel.text = "A"
        self.weekLabel.font = bodyFont
        self.weekLabel.textColor = .clear
        self.weekLabel.textAlignment = .center
        self.weekLabel.numberOfLines = 1
        self.addSubview(self.weekLabel)
        
        self.dateLabel.text = "A"
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .clear
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.addSubview(self.dateLabel)
        self.addSubview(self.horizontalLinesView)
        
        self.weekLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.weekLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.horizontalLinesView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin + mainTrendIconSize)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-littleMargin - mainTrendIconSize)
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
