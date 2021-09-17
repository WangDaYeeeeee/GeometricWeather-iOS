//
//  TrendConstants.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/15.
//

import UIKit

let trendPolylineWidth = 4.0
let trendHistogramWidth = 8.0
let trendTimelineWidth = 0.5
let trendHorizontalLineWidth = 0.5
let trendPaddingTop = 24.0
let trendPaddingBottom = 36.0
let trendTextMargin = 4.0

let trendPrecipitationAlpha = 0.35
let trendTimelineAlpha = 0.1
let trendHorizontalLineAlpha = 0.15

let trendTimelineZ = -1.0
let trendShadowZ = 0.0
let trendHistogramZ = 1.0
let trendPolylineZ = 2.0
let trendSubviewsZ = 3.0

typealias PolylineTrend = (start: Double?, center: Double, end: Double?)
typealias HorizontalLineDescription = (leading: String, trailing: String)

func rtlX(_ x: CGFloat, width: CGFloat, rtl: Bool) -> CGFloat {
    return (rtl ? (1.0 - x) : x) * width
}

func y(_ y: CGFloat, height: CGFloat) -> CGFloat {
    return height - trendPaddingBottom - y * (
        height - trendPaddingTop - trendPaddingBottom
    )
}
