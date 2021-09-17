//
//  MainTrendUtils.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import Foundation

let mainTrendInnerMargin = littleMargin / 2
let mainTrendIconSize = 32.0

typealias TemperatureRange = (min: Int, max: Int)

func getY(
    value: Double,
    min: Double,
    max: Double
) -> Double {
    return (value - min) / (max - min)
}
