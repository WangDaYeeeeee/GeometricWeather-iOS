//
//  HourlyDialog.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/22.
//

import Foundation
import GeometricWeatherBasic

private let headerIconSize = 44.0

class HourlyDialog: GeoDialog {
    
    init(weather: Weather, timezone: TimeZone, index: Int) {
        super.init(
            HourlyView(
                weather: weather,
                timezone: timezone,
                index: index
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
