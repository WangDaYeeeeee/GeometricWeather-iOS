//
//  MainDailyCardCell+Tags.swift
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
private let temperatureTrendPaddingBottom = 40.0
private let naturalTrendPaddingBottom = normalMargin

private let naturalBackgroundIconPadding = littleMargin + mainTrendIconSize

private let maxPrecipitationIntensity = radarPrecipitationIntensityHeavy

extension MainDailyCardCell {
    
    func buildTagList(weather: Weather) -> [(tag: DailyTag, title: String)] {
        var tags = [(DailyTag.temperature, getLocalizedText("temperature"))]
        
        // wind.
        for daily in weather.dailyForecasts {
            if daily.wind != nil {
                tags.append(
                    (DailyTag.wind, getLocalizedText("wind"))
                )
                break
            }
        }
        
        // aqi.
        for daily in weather.dailyForecasts {
            if daily.airQuality.isValid() {
                tags.append(
                    (DailyTag.aqi, getLocalizedText("air_quality"))
                )
                break
            }
        }
        
        // uv.
        for daily in weather.dailyForecasts {
            if daily.uv.isValid() {
                tags.append(
                    (DailyTag.uv, getLocalizedText("uv_index"))
                )
                break
            }
        }
        
        // precipitation.
        tags.append((DailyTag.precipitationIntensity, getLocalizedText("precipitation_intensity")))
        
        return tags
    }
    
    func registerCells(collectionView: UICollectionView) {
        collectionView.register(
            DailyTemperatureCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.temperature.rawValue
        )
        collectionView.register(
            DailySingleWindCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.wind.rawValue
        )
        collectionView.register(
            DailyAirQualityCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.aqi.rawValue
        )
        collectionView.register(
            DailyUVCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.uv.rawValue
        )
        collectionView.register(
            DailyPrecipitationCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.precipitationIntensity.rawValue
        )
    }
    
    func buildCell(
        collectionView: UICollectionView,
        currentTag: DailyTag,
        indexPath: IndexPath,
        weather: Weather?,
        source: WeatherSource?,
        timezone: TimeZone,
        temperatureRange: ClosedRange<Int>,
        maxWindSpeed: Double,
        maxAqiIndex: Int,
        maxUVIndex: Int
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: currentTag.rawValue,
            for: indexPath
        )
        
        if let weather = weather, let source = source {
            switch currentTag {
            case .temperature:
                if let cell = cell as? DailyTemperatureCollectionViewCell {
                    cell.bindData(
                        daily: weather.dailyForecasts[indexPath.row],
                        temperatureRange: temperatureRange,
                        weatherCode: weather.current.weatherCode,
                        timezone: timezone,
                        histogramType: self.getPrecipitationHistogramType(
                            weather: weather,
                            source: source
                        )
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = temperatureTrendPaddingBottom
                }
            case .wind:
                if let cell = cell as? DailySingleWindCollectionViewCell {
                    cell.bindData(
                        daily: weather.dailyForecasts[indexPath.row],
                        maxWindSpeed: maxWindSpeed,
                        timezone: timezone
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = naturalTrendPaddingBottom
                }
            case .aqi:
                if let cell = cell as? DailyAirQualityCollectionViewCell {
                    cell.bindData(
                        daily: weather.dailyForecasts[indexPath.row],
                        maxAqiIndex: maxAqiIndex,
                        timezone: timezone
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = naturalTrendPaddingBottom
                }
            case .uv:
                if let cell = cell as? DailyUVCollectionViewCell {
                    cell.bindData(
                        daily: weather.dailyForecasts[indexPath.row],
                        maxAqiIndex: maxUVIndex,
                        timezone: timezone
                    )
                    cell.trendPaddingTop = naturalTrendPaddingTop
                    cell.trendPaddingBottom = naturalTrendPaddingBottom
                }
            case .precipitationIntensity:
                if let cell = cell as? DailyPrecipitationCollectionViewCell {
                    cell.bindData(
                        daily: weather.dailyForecasts[indexPath.row],
                        timezone: timezone,
                        histogramType: .precipitationIntensity(max: maxPrecipitationIntensity)
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
        currentTag: DailyTag,
        weather: Weather?,
        source: WeatherSource?,
        timezone: TimeZone,
        temperatureRange: ClosedRange<Int>,
        maxWindSpeed: Double,
        maxAqiIndex: Int,
        maxUVIndex: Int
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
                paddingBottom: temperatureTrendPaddingBottom + naturalBackgroundIconPadding
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
            
        case .aqi:
            let highLines = [
                (index: aqiIndexLevel1, desc: getLocalizedText("aqi_1")),
                (index: aqiIndexLevel3, desc: getLocalizedText("aqi_3")),
                (index: aqiIndexLevel5, desc: getLocalizedText("aqi_5")),
            ].filter { item in
                item.index <= maxAqiIndex
            }.map { item in
                HorizontalLine(
                    value: Double(item.index) / Double(maxAqiIndex),
                    leadingDescription: String(item.index),
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
            
        case .uv:
            let highLines = [
                uvIndexLevelLow,
                uvIndexLevelMiddle,
                uvIndexLevelHigh,
            ].filter { item in
                item <= maxUVIndex
            }.map { item in
                HorizontalLine(
                    value: Double(item) / Double(maxUVIndex),
                    leadingDescription: String(item),
                    trailingDescription: ""
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
                paddingBottom: naturalTrendPaddingBottom + naturalBackgroundIconPadding
            )
        }
    }
    
    private func getPrecipitationHistogramType(
        weather: Weather,
        source: WeatherSource
    ) -> DailyPrecipitationHistogramType {
        if source.hasDailyPrecipitationProb {
            return .precipitationProb
        }
        if source.hasDailyPrecipitationTotal {
            return .precipitationTotal(max: dailyPrecipitationHeavy)
        }
        if source.hasDailyPrecipitationIntensity {
            return .precipitationIntensity(max: radarPrecipitationIntensityHeavy)
        }
        return DailyPrecipitationHistogramType.none
    }
}
