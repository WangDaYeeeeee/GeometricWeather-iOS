//
//  UpdateHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/5/5.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherUpdate
import GeometricWeatherSettings

extension UpdateHelper {
    
    func update(
        target: Location,
        inBackground: Bool
    ) async -> UpdateResult {
        return await self.update(
            for: target,
            by: UnitSet(
                temperatureUnit: SettingsManager.shared.temperatureUnit,
                speedUnit: SettingsManager.shared.speedUnit,
                pressureUnit: SettingsManager.shared.pressureUnit,
                precipitationUnit: SettingsManager.shared.precipitationUnit,
                precipitationIntensityUnit: SettingsManager.shared.precipitationIntensityUnit,
                distanceUnit: SettingsManager.shared.distanceUnit
            ),
            with: SettingsManager.shared.weatherSource,
            inBackground: inBackground
        )
    }
}
