//
//  DailyTemperatureCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/14.
//

import UIKit
import GeometricWeatherBasic

class DailyTemperatureCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let daytimeIcon = UIImageView(frame: .zero)
    private let nighttimeIcon = UIImageView(frame: .zero)
    
    private let trendView = HistogramView(frame: .zero)
    
    // MARK: - inner data.
    
    private var weatherCode: WeatherCode?
    
    var trendPaddingTop: CGFloat {
        get {
            return self.trendView.paddingTop
        }
        set {
            self.trendView.paddingTop = newValue
        }
    }
    
    var trendPaddingBottom: CGFloat {
        get {
            return self.trendView.paddingBottom
        }
        set {
            self.trendView.paddingBottom = newValue
        }
    }
    
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
        daily: Daily,
        temperatureRange: ClosedRange<Int>,
        weatherCode: WeatherCode,
        timezone: TimeZone,
        histogramType: DailyPrecipitationHistogramType
    ) {
        self.weatherCode = weatherCode
        
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? getLocalizedText("today")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: getLocalizedText("date_format_short")
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
        
        self.trendView.highValue = getY(
            value: Double(daily.day.temperature.temperature),
            min: Double(temperatureRange.lowerBound),
            max: Double(temperatureRange.upperBound)
        )
        self.trendView.lowValue = getY(
            value: Double(daily.night.temperature.temperature),
            min: Double(temperatureRange.lowerBound),
            max: Double(temperatureRange.upperBound)
        )
        
        switch histogramType {
        case .precipitationProb:
            let precipitationProb = max(
                daily.day.precipitationProbability ?? 0.0,
                daily.night.precipitationProbability ?? 0.0,
                daily.precipitationProbability ?? 0.0
            )
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
            
        case .precipitationTotal:
            let precipitationTotal = max(
                daily.day.precipitationTotal ?? 0.0,
                daily.night.precipitationTotal ?? 0.0,
                daily.precipitationTotal ?? 0.0
            )
            if precipitationTotal > 0 {
                let unit = SettingsManager.shared.precipitationUnit
                
                self.trendView.bottomDescription = (
                    unit.formatValueWithUnit(
                        precipitationTotal,
                        unit: ""
                    ),
                    ""
                )
            } else {
                self.trendView.bottomDescription = nil
            }
            
        case .precipitationIntensity:
            let precipitationIntensity = max(
                daily.day.precipitationIntensity ?? 0.0,
                daily.night.precipitationIntensity ?? 0.0,
                daily.precipitationIntensity ?? 0.0
            )
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
                daily.day.temperature.temperature,
                unit: ""
            ),
            "°"
        )
        self.trendView.lowDescription = (
            tempUnit.formatValueWithUnit(
                daily.night.temperature.temperature,
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
}
