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
    
    func suspendedReadLocations() async -> [Location] {
        return await self.suspendedReadLocations(defualtWeatherSource: SettingsManager.shared.weatherSource)
    }
    
    func readLocations() -> [Location] {
        return self.readLocations(defualtWeatherSource: SettingsManager.shared.weatherSource)
    }
}
