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

// MARK: - generator.

class HourlyTemperatureTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private let temperatureRange: ClosedRange<Int>
    private let histogramType: HourlyPrecipitationHistogramType
    
    // properties.
    
    var dispayName: String {
        return getLocalizedText("temperature")
    }
    
    var isValid: Bool {
        return true
    }
    
    // life cycle.
    
    required init(_ location: Location) {
        self.location = location
        
        var maxTemp = location.weather?.yesterday?.daytimeTemperature ?? Int.min
        var minTemp = location.weather?.yesterday?.nighttimeTemperature ?? Int.max
        var histogramType = HourlyPrecipitationHistogramType.none
        location.weather?.hourlyForecasts.forEach { hourly in
            if maxTemp < hourly.temperature.temperature {
                maxTemp = hourly.temperature.temperature
            }
            if minTemp > hourly.temperature.temperature {
                minTemp = hourly.temperature.temperature
            }
            
            if histogramType != .none {
                return
            }
            if hourly.precipitationProbability != nil {
                histogramType = .precipitationProb
                return
            }
            if hourly.precipitationIntensity != nil {
                histogramType = .precipitationIntensity(max: precipitationIntensityHeavy)
                return
            }
        }
        self.temperatureRange = minTemp...maxTemp
        self.histogramType = histogramType
    }
    
    // interfaces.
    
    static func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            HourlyTemperatureCollectionViewCell.self,
            forCellWithReuseIdentifier: Self.key
        )
    }
    
    func bindCellData(
        at indexPath: IndexPath,
        to collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.key,
            for: indexPath
        )
        
        if let weather = self.location.weather,
           let cell = cell as? HourlyTemperatureCollectionViewCell {
            
            var useAccentColorForDate = indexPath.row == 0
            if weather
               .hourlyForecasts[indexPath.row]
               .getHour(inTwelveHourFormat: false) == 0 {
                useAccentColorForDate = true
            }
            
            cell.bindData(
                hourly: weather.hourlyForecasts[indexPath.row],
                temperatureRange: self.temperatureRange,
                weatherCode: weather.current.weatherCode,
                timezone: self.location.timezone,
                daylight: self.location.isDaylight,
                histogramType: self.histogramType,
                useAccentColorForDate: useAccentColorForDate
            )
            cell.trendPaddingTop = naturalTrendPaddingTop
            cell.trendPaddingBottom = temperatureTrendPaddingBottom
        }
        
        return cell
    }
    
    func bindCellBackground(to trendBackgroundView: MainTrendBackgroundView) {
        guard let weather = self.location.weather else {
            trendBackgroundView.bindData(highLines: [], lowLines: [], lineColor: .clear)
            return
        }
        
        guard
            let yesterdayHigh = weather.yesterday?.daytimeTemperature,
            let yesterdayLow = weather.yesterday?.nighttimeTemperature
        else {
            trendBackgroundView.bindData(highLines: [], lowLines: [], lineColor: .clear)
            return
        }
        trendBackgroundView.bindData(
            highLines: [HorizontalLine(
                value: Double(
                    yesterdayHigh - self.temperatureRange.lowerBound
                ) / Double(
                    self.temperatureRange.upperBound - self.temperatureRange.lowerBound
                ),
                leadingDescription: SettingsManager.shared.temperatureUnit.formatValue(yesterdayHigh) + "º",
                trailingDescription: getLocalizedText("yesterday")
            )],
            lowLines: [HorizontalLine(
                value: Double(
                    yesterdayLow - self.temperatureRange.lowerBound
                ) / Double(
                    self.temperatureRange.upperBound - self.temperatureRange.lowerBound
                ),
                leadingDescription: SettingsManager.shared.temperatureUnit.formatValue(yesterdayLow) + "º",
                trailingDescription: getLocalizedText("yesterday")
            )],
            lineColor: mainTrendBackgroundLineColor,
            paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
            paddingBottom: temperatureTrendPaddingBottom
        )
    }
}

// MARK: - cell.

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
        daylight: Bool,
        histogramType: HourlyPrecipitationHistogramType,
        useAccentColorForDate: Bool
    ) {
        self.weatherCode = weatherCode
        
        self.hourLabel.text = getHourText(hourly)
        
        self.dateLabel.text = hourly.formatDate(
            format: getLocalizedText("date_format_short")
        )
        self.dateLabel.textColor = useAccentColorForDate
        ? .label
        : .tertiaryLabel
        self.dateLabel.font = useAccentColorForDate
        ? .systemFont(ofSize: miniCaptionFont.pointSize, weight: .bold)
        : miniCaptionFont
        
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
        
        self.trendView.color = UIColor(
            ThemeManager.weatherThemeDelegate.getThemeColor(
                weatherKind: weatherCodeToWeatherKind(code: weatherCode),
                daylight: daylight
            )
        )
        self.trendView.bottomLabel.textColor = precipitationProbabilityColor
        
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
        
    }
}
