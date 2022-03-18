//
//  MainTrendUtils.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import Foundation
import GeometricWeatherBasic

let mainTrendInnerMargin = littleMargin / 2
let mainTrendIconSize = 32.0
let mainWindIconSize = 16.0

enum DailyPrecipitationHistogramType {
    case precipitationProb
    case precipitationTotal
    case precipitationIntensity
    case none
}

enum HourlyPrecipitationHistogramType {
    case precipitationProb
    case precipitationIntensity
    case none
}

func getY(
    value: Double,
    min: Double,
    max: Double
) -> Double {
    return (value - min) / (max - min)
}
