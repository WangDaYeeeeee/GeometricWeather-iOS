//
//  DatabaseHelperExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/5/5.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherDB
import GeometricWeatherSettings

extension DatabaseHelper {
    
    func asyncReadLocations() async -> [Location] {
        return await self.asyncReadLocations(defualtWeatherSource: SettingsManager.shared.weatherSource)
    }
    
    @available(*, deprecated, renamed: "asyncReadLocations", message: "Prefer to use an alernative async method.")
    func readLocations() -> [Location] {
        return self.readLocations(defualtWeatherSource: SettingsManager.shared.weatherSource)
    }
}
