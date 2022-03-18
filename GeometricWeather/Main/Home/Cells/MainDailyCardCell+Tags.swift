//
//  MainDailyCardCell+Tags.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/25.
//

import Foundation
import GeometricWeatherBasic

extension MainDailyCardCell {
    
    func buildTagList(weather: Weather) -> [(tag: DailyTag, title: String)] {
        var tags = [(DailyTag.temperature, NSLocalizedString("temperature", comment: ""))]
        
        // wind.
        for daily in weather.dailyForecasts {
            if daily.wind != nil {
                tags.append(
                    (DailyTag.wind, NSLocalizedString("wind", comment: ""))
                )
                break
            }
        }
        
        // aqi.
        for daily in weather.dailyForecasts {
            if daily.airQuality.isValid() {
                tags.append(
                    (DailyTag.aqi, NSLocalizedString("air_quality", comment: ""))
                )
                break
            }
        }
        
        // uv.
        for daily in weather.dailyForecasts {
            if daily.uv.isValid() {
                tags.append(
                    (DailyTag.uv, NSLocalizedString("uv_index", comment: ""))
                )
                break
            }
        }
        
        // precipitation.
        tags.append((DailyTag.precipitation, NSLocalizedString("precipitation", comment: "")))
        
        return tags
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
            var histogramType = DailyPrecipitationHistogramType.none
            if source.hasDailyPrecipitationProb {
                histogramType = .precipitationProb
            }
            if source.hasDailyPrecipitationTotal {
                histogramType = .precipitationTotal
            }
            if source.hasDailyPrecipitationIntensity {
                histogramType = .precipitationIntensity
            }
            
            switch currentTag {
            case .temperature:
                (cell as? DailyTrendCollectionViewCell)?.bindData(
                    daily: weather.dailyForecasts[indexPath.row],
                    temperatureRange: temperatureRange,
                    weatherCode: weather.current.weatherCode,
                    timezone: timezone,
                    histogramType: histogramType
                )
            case .wind:
                (cell as? DailySingleWindCollectionViewCell)?.bindData(
                    daily: weather.dailyForecasts[indexPath.row],
                    maxWindSpeed: maxWindSpeed,
                    timezone: timezone
                )
            case .aqi:
                (cell as? DailyAirQualityCollectionViewCell)?.bindData(
                    daily: weather.dailyForecasts[indexPath.row],
                    maxAqiIndex: maxAqiIndex,
                    timezone: timezone
                )
            case .uv:
                (cell as? DailyUVCollectionViewCell)?.bindData(
                    daily: weather.dailyForecasts[indexPath.row],
                    maxAqiIndex: maxUVIndex,
                    timezone: timezone
                )
            case .precipitation:
                (cell as? DailyPrecipitationCollectionViewCell)?.bindData(
                    daily: weather.dailyForecasts[indexPath.row],
                    timezone: timezone,
                    histogramType: histogramType
                )
            }
        }
        
        return cell
    }
}
