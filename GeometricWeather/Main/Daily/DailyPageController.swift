//
//  DailyPageController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/27.
//

import Foundation
import SwiftUI
import GeometricWeatherBasic

class DailyPageController: UIHostingController<DailyView> {
    
    init(
        weather: Weather,
        index: Int,
        timezone: TimeZone
    ) {
        super.init(
            rootView: DailyView(
                weather: weather,
                index: index,
                timezone: timezone
            )
        )
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
