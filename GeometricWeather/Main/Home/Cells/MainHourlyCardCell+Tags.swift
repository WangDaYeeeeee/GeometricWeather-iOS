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
            switch currentTag {
            case .temperature:
                var histogramType = HourlyHistogramType.none
                if source.hasHourlyPrecipitationProb {
                    histogramType = .precipitationProb
                }
                if source.hasHourlyPrecipitationIntensity {
                    histogramType = .precipitationIntensity
                }
                
                (cell as? HourlyTrendCollectionViewCell)?.bindData(
                    prev: indexPath.row == 0
                    ? nil
                    : weather.hourlyForecasts[indexPath.row - 1],
                    hourly: weather.hourlyForecasts[indexPath.row],
                    next: indexPath.row == weather.hourlyForecasts.count - 1
                    ? nil
                    : weather.hourlyForecasts[indexPath.row + 1],
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
            }
        }
        
        return cell
    }
}
