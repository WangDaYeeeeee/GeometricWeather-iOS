//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/5/5.
//

import Foundation

public struct UnitSet {
    
    public let temperatureUnit: TemperatureUnit
    public let speedUnit: SpeedUnit
    public let pressureUnit: PressureUnit
    public let precipitationUnit: PrecipitationUnit
    public let precipitationIntensityUnit: PrecipitationIntensityUnit
    public let distanceUnit: DistanceUnit
    
    public init(
        temperatureUnit: TemperatureUnit,
        speedUnit: SpeedUnit,
        pressureUnit: PressureUnit,
        precipitationUnit: PrecipitationUnit,
        precipitationIntensityUnit: PrecipitationIntensityUnit,
        distanceUnit: DistanceUnit
    ) {
        self.temperatureUnit = temperatureUnit
        self.speedUnit = speedUnit
        self.pressureUnit = pressureUnit
        self.precipitationUnit = precipitationUnit
        self.precipitationIntensityUnit = precipitationIntensityUnit
        self.distanceUnit = distanceUnit
    }
}
