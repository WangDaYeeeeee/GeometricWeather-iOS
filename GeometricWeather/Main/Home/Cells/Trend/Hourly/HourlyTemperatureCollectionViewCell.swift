//
//  HourlyTemperatureCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class HourlyTemperatureCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        hourly: Hourly,
        temperatureRange: ClosedRange<Int>,
        weatherCode: WeatherCode,
        timezone: TimeZone,
        histogramType: HourlyPrecipitationHistogramType,
        useAccentColorForDate: Bool
    ) {
        self.weatherCode = weatherCode
        
        self.hourLabel.text = getHourText(
            hour: hourly.getHour(
                isTwelveHour(),
                timezone: timezone
            )
        )
        
        self.dateLabel.text = hourly.formatDate(
            format: getLocalizedText("date_format_short")
        )
        self.dateLabel.textColor = useAccentColorForDate
        ? .secondaryLabel
        : .tertiaryLabel
        
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
            daylight: self.window?.windowScene?.themeManager.daylight.value ?? true
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
        self.trendView.color = UIColor(
            ThemeManager.weatherThemeDelegate.getThemeColor(
                weatherKind: weatherCodeToWeatherKind(code: weatherCode),
                daylight: daylight
            )
        )
        self.trendView.bottomLabel.textColor = precipitationProbabilityColor
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        newWindow?.windowScene?.themeManager.daylight.addNonStickyObserver(self) { daylight in
            if self.weatherCode == nil {
                return
            }
            
            self.updateTrendColors(
                weatherCode: self.weatherCode ?? .clear,
                daylight: daylight
            )
        }
    }
}
