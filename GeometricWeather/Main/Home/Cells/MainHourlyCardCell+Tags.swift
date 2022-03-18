//
//  MainHourlyCardCell+Tags.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/25.
//

import Foundation
import GeometricWeatherBasic

extension MainHourlyCardCell {
    
    func buildTagList(weather: Weather) -> [(tag: HourlyTag, title: String)] {
        var tags = [(HourlyTag.temperature, NSLocalizedString("temperature", comment: ""))]
        
        // wind.
        for hourly in weather.hourlyForecasts {
            if hourly.wind != nil {
                tags.append(
                    (HourlyTag.wind, NSLocalizedString("wind", comment: ""))
                )
                break
            }
        }
        
        // precipitation.
        tags.append((HourlyTag.precipitation, NSLocalizedString("precipitation", comment: "")))
        
        return tags
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
            var histogramType = HourlyPrecipitationHistogramType.none
            if source.hasHourlyPrecipitationProb {
                histogramType = .precipitationProb
            }
            if source.hasHourlyPrecipitationIntensity {
                histogramType = .precipitationIntensity
            }
            
            switch currentTag {
            case .temperature:
                (cell as? HourlyTrendCollectionViewCell)?.bindData(
                    hourly: weather.hourlyForecasts[indexPath.row],
                    temperatureRange: temperatureRange,
                    weatherCode: weather.current.weatherCode,
                    timezone: timezone,
                    histogramType: histogramType
                )
            case .wind:
                (cell as? HourlyWindCollectionViewCell)?.bindData(
                    hourly: weather.hourlyForecasts[indexPath.row],
                    maxWindSpeed: maxWindSpeed,
                    timezone: timezone
                )
            case .precipitation:
                (cell as? HourlyPrecipitationCollectionViewCell)?.bindData(
                    hourly: weather.hourlyForecasts[indexPath.row],
                    timezone: timezone,
                    histogramType: histogramType
                )
            }
        }
        
        return cell
    }
}
