//
//  MainHourlyCardCell+Tags.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/25.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let naturalTrendPaddingTop = 24.0
private let naturalTrendPaddingBottom = normalMargin

private let naturalBackgroundIconPadding = littleMargin + mainTrendIconSize

private let maxPrecipitationIntensity = radarPrecipitationIntensityHeavy

extension MainHourlyCardCell {
    
    func buildTagList(weather: Weather) -> [(tag: HourlyTag, title: String)] {
        var tags = [(HourlyTag.temperature, getLocalizedText("temperature"))]
        
        // wind.
        for hourly in weather.hourlyForecasts {
            if hourly.wind != nil {
                tags.append(
                    (HourlyTag.wind, getLocalizedText("wind"))
                )
                break
            }
        }
        
        // precipitation.
        for hourly in weather.hourlyForecasts {
            if hourly.precipitationIntensity != nil {
                tags.append(
                    (HourlyTag.precipitationIntensity, getLocalizedText("precipitation_intensity"))
                )
                break
            }
        }
        
        return tags
    }
    
    func registerCells(collectionView: UICollectionView) {
        collectionView.register(
            HourlyTemperatureCollectionViewCell.self,
            forCellWithReuseIdentifier: HourlyTag.temperature.rawValue
        )
        collectionView.register(
            HourlyWindCollectionViewCell.self,
            forCellWithReuseIdentifier: HourlyTag.wind.rawValue
        )
        collectionView.register(
            HourlyPrecipitationCollectionViewCell.self,
            forCellWithReuseIdentifier: HourlyTag.precipitationIntensity.rawValue
        )
    }
    
    func buildCell(
        collectionView: UICollectionView,
        currentTag: HourlyTag,
        indexPath: IndexPath,
        weather: Weather?,
        source: WeatherSource?,
        timezone: TimeZone,
        temperatureRange: ClosedRange<Int>,
        maxWindSpeed: Double
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: currentTag.rawValue,
            for: indexPath
        )
        
        if let weather = weather, let source = source {
            let useAccentColorForDate = indexPath.row == 0
            || weather.hourlyForecasts[indexPath.row].getHour(false, timezone: timezone) == 0
            
            switch currentTag {
            case .temperature:
                if let cell = cell as? HourlyTemperatureCollectionViewCell {
                    cell.bindData(
                        hourly: weather.hourlyForecasts[indexPath.row],
                        temperatureRange: temperatureRange,
                        weatherCode: weather.current.weatherCode,
                        timezone: timezone,
                        histogramType: self.getPrecipitationHistogramType(
                            weather: weather,
                            source: source
                        ),
                        useAccentColorForDate: useAccentColorForDate
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = naturalTrendPaddingBottom
                }
            case .wind:
                if let cell = cell as? HourlyWindCollectionViewCell {
                    cell.bindData(
                        hourly: weather.hourlyForecasts[indexPath.row],
                        maxWindSpeed: maxWindSpeed,
                        timezone: timezone,
                        useAccentColorForDate: useAccentColorForDate
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = naturalTrendPaddingBottom
                }
            case .precipitationIntensity:
                if let cell = cell as? HourlyPrecipitationCollectionViewCell {
                    cell.bindData(
                        hourly: weather.hourlyForecasts[indexPath.row],
                        timezone: timezone,
                        histogramType: .precipitationIntensity(max: maxPrecipitationIntensity),
                        useAccentColorForDate: useAccentColorForDate
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = naturalTrendPaddingBottom
                }
            }
        }
        
        return cell
    }
    
    func bindTrendBackground(
        trendBackgroundView: MainTrendBackgroundView,
        currentTag: HourlyTag,
        weather: Weather?,
        source: WeatherSource?,
        timezone: TimeZone,
        temperatureRange: ClosedRange<Int>,
        maxWindSpeed: Double
    ) {
        guard let weather = weather else {
            trendBackgroundView.bindData(highLines: [], lowLines: [], lineColor: .clear)
            return
        }

        let lineColor = UIColor.tertiaryLabel.withAlphaComponent(0.15)
        
        switch currentTag {
        case .temperature:
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
                        yesterdayHigh - temperatureRange.lowerBound
                    ) / Double(
                        temperatureRange.upperBound - temperatureRange.lowerBound
                    ),
                    leadingDescription: SettingsManager.shared.temperatureUnit.formatValue(yesterdayHigh) + "º",
                    trailingDescription: getLocalizedText("yesterday")
                )],
                lowLines: [HorizontalLine(
                    value: Double(
                        yesterdayLow - temperatureRange.lowerBound
                    ) / Double(
                        temperatureRange.upperBound - temperatureRange.lowerBound
                    ),
                    leadingDescription: SettingsManager.shared.temperatureUnit.formatValue(yesterdayLow) + "º",
                    trailingDescription: getLocalizedText("yesterday")
                )],
                lineColor: lineColor,
                paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
                paddingBottom: naturalTrendPaddingBottom
            )
            
        case .wind:
            let highLines = [
                (speed: windSpeedLevel3, desc: getLocalizedText("wind_3")),
                (speed: windSpeedLevel5, desc: getLocalizedText("wind_5")),
                (speed: windSpeedLevel7, desc: getLocalizedText("wind_7")),
                (speed: windSpeedLevel10, desc: getLocalizedText("wind_10")),
            ].filter { item in
                item.speed <= maxWindSpeed
            }.map { item in
                HorizontalLine(
                    value: item.speed / maxWindSpeed,
                    leadingDescription: SettingsManager.shared.speedUnit.formatValue(item.speed),
                    trailingDescription: item.desc
                )
            }
            trendBackgroundView.bindData(
                highLines: highLines,
                lowLines: [],
                lineColor: lineColor,
                paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
                paddingBottom: naturalTrendPaddingBottom
            )
            
        case .precipitationIntensity:
            let highLines = [
                (mmph: radarPrecipitationIntensityMiddle, desc: getLocalizedText("precipitation_middle")),
                (mmph: radarPrecipitationIntensityHeavy, desc: getLocalizedText("precipitation_heavy")),
                (mmph: radarPrecipitationIntensityRainstrom, desc: getLocalizedText("precipitation_rainstorm")),
            ].filter { item in
                item.mmph <= maxPrecipitationIntensity
            }.map { item in
                HorizontalLine(
                    value: item.mmph / maxPrecipitationIntensity,
                    leadingDescription: SettingsManager.shared.precipitationIntensityUnit.formatValue(item.mmph),
                    trailingDescription: item.desc
                )
            }
            trendBackgroundView.bindData(
                highLines: highLines,
                lowLines: [],
                lineColor: lineColor,
                paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
                paddingBottom: naturalTrendPaddingBottom
            )
        }
    }
    
    private func getPrecipitationHistogramType(
        weather: Weather,
        source: WeatherSource
    ) -> HourlyPrecipitationHistogramType {
        if source.hasHourlyPrecipitationProb {
            return .precipitationProb
        }
        if source.hasHourlyPrecipitationIntensity {
            return .precipitationIntensity(max: radarPrecipitationIntensityHeavy)
        }
        return .none
    }
}
