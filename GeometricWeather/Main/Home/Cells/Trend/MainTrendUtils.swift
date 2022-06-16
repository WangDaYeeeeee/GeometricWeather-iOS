//
//  MainTrendUtils.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

let mainTrendInnerMargin = littleMargin / 2
let mainTrendIconSize = 32.0
let mainWindIconSize = 16.0

let naturalTrendPaddingTop = 24.0
let temperatureTrendPaddingBottom = 40.0
let naturalTrendPaddingBottom = normalMargin

let naturalBackgroundIconPadding = littleMargin + mainTrendIconSize

let mainTrendBackgroundLineColor = UIColor.tertiaryLabel.withAlphaComponent(0.15)

enum DailyPrecipitationHistogramType: Equatable {
    case precipitationProb
    case precipitationTotal(max: Double)
    case precipitationIntensity(max: Double)
    case none
}

enum HourlyPrecipitationHistogramType: Equatable {
    case precipitationProb
    case precipitationIntensity(max: Double)
    case none
}

func getY(
    value: Double,
    min: Double,
    max: Double
) -> Double {
    return (value - min) / (max - min)
}
