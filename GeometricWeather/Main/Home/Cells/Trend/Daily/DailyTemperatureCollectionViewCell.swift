//
//  DailyTemperatureCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/14.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - generator.

class DailyTemperatureTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private let temperatureRange: ClosedRange<Int>
    private let histogramType: DailyPrecipitationHistogramType
    
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
        var histogramType = DailyPrecipitationHistogramType.none
        location.weather?.dailyForecasts.forEach { daily in
            if maxTemp < daily.day.temperature.temperature {
                maxTemp = daily.day.temperature.temperature
            }
            if minTemp > daily.night.temperature.temperature {
                minTemp = daily.night.temperature.temperature
            }
            
            if histogramType != .none {
                return
            }
            if daily.precipitationProbability != nil
                || daily.day.precipitationProbability != nil
                || daily.night.precipitationProbability != nil {
                histogramType = .precipitationProb
                return
            }
            if daily.precipitationTotal != nil
                || daily.day.precipitationTotal != nil
                || daily.night.precipitationTotal != nil {
                histogramType = .precipitationTotal(max: dailyPrecipitationHeavy)
                return
            }
            if daily.precipitationIntensity != nil
                || daily.day.precipitationIntensity != nil
                || daily.night.precipitationIntensity != nil {
                histogramType = .precipitationIntensity(max: precipitationIntensityHeavy)
                return
            }
        }
        self.temperatureRange = minTemp...maxTemp
        self.histogramType = histogramType
    }
    
    // interfaces.
    
    func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            DailyTemperatureCollectionViewCell.self,
            forCellWithReuseIdentifier: self.key
        )
    }
    
    func bindCellData(
        at indexPath: IndexPath,
        to collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: self.key,
            for: indexPath
        )
        
        if let weather = self.location.weather,
           let cell = cell as? DailyTemperatureCollectionViewCell {
            cell.bindData(
                daily: weather.dailyForecasts[indexPath.row],
                temperatureRange: self.temperatureRange,
                weatherCode: weather.current.weatherCode,
                timezone: self.location.timezone,
                daylight: self.location.isDaylight,
                histogramType: self.histogramType
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
            paddingBottom: temperatureTrendPaddingBottom + naturalBackgroundIconPadding
        )
    }
}

// MARK: - cell.

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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        daily: Daily,
        temperatureRange: ClosedRange<Int>,
        weatherCode: WeatherCode,
        timezone: TimeZone,
        daylight: Bool,
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
}
