//
//  Units.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

// MARK: - set.

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

// MARK: - temperature.

public struct TemperatureUnit: Unit {
    
    public typealias ImplType = TemperatureUnit
    public typealias ValueType = Int
    
    public static let c = TemperatureUnit(
        key: "temperature_unit_c",
        voiceKey: "temperature_unit_voice_c",
        valueConterver: { (value: Int) -> Int in
            return value
        }
    )
    public static let f = TemperatureUnit(
        key: "temperature_unit_f",
        voiceKey: "temperature_unit_voice_f",
        valueConterver: { (value: Int) -> Int in
            return Int(32 + 1.8 * Double(value))
        }
    )
    public static let k = TemperatureUnit(
        key: "temperature_unit_k",
        voiceKey: "temperature_unit_voice_k",
        valueConterver: { (value: Int) -> Int in
            return Int(273.15 + Double(value))
        }
    )
    
    public static let all = [c, f, k]
    
    public static subscript(index: Int) -> TemperatureUnit {
        get {
            return TemperatureUnit.all[index]
        }
    }
    
    public static subscript(key: String) -> TemperatureUnit {
        get {
            for item in TemperatureUnit.all {
                if item.key == key {
                    return item
                }
            }
            return TemperatureUnit.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let valueConterver: ValueConverter<Int>
    
    private init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Int>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    public func getValue(_ valueInDefaultType: Int) -> Int {
        return valueConterver(valueInDefaultType)
    }
    
    public func formatValue(_ valueInDefaultType: Int) -> String {
        return String(getValue(valueInDefaultType))
    }
    
    public func formatValueWithUnit(_ valueInDefaultType: Int, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - speed.

public struct SpeedUnit: Unit {
    
    public typealias ImplType = SpeedUnit
    public typealias ValueType = Double
    
    public static let kph = SpeedUnit(
        key: "speed_unit_kph",
        voiceKey: "speed_unit_voice_kph",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    public static let mps = SpeedUnit(
        key: "speed_unit_mps",
        voiceKey: "speed_unit_voice_mps",
        valueConterver: { (value: Double) -> Double in
            return value / 3.6
        }
    )
    public static let kn = SpeedUnit(
        key: "speed_unit_kn",
        voiceKey: "speed_unit_voice_kn",
        valueConterver: { (value: Double) -> Double in
            return value / 1.852
        }
    )
    public static let mph = SpeedUnit(
        key: "speed_unit_mph",
        voiceKey: "speed_unit_voice_mph",
        valueConterver: { (value: Double) -> Double in
            return value / 1.609
        }
    )
    public static let ftps = SpeedUnit(
        key: "speed_unit_ftps",
        voiceKey: "speed_unit_voice_ftps",
        valueConterver: { (value: Double) -> Double in
            return value * 0.9113
        }
    )
    
    public static let all = [kph, mps, kn, mph, ftps]
    
    public static subscript(index: Int) -> SpeedUnit {
        get {
            return SpeedUnit.all[index]
        }
    }
    
    public static subscript(key: String) -> SpeedUnit {
        get {
            for item in SpeedUnit.all {
                if item.key == key {
                    return item
                }
            }
            return SpeedUnit.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let valueConterver: ValueConverter<Double>
    
    private init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    public func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    public func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    public func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - pressure.

public struct PressureUnit: Unit {
    
    public typealias ImplType = PressureUnit
    public typealias ValueType = Double
    
    public static let mb = PressureUnit(
        key: "pressure_unit_mb",
        voiceKey: "pressure_unit_voice_mb",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    public static let kpa = PressureUnit(
        key: "pressure_unit_kpa",
        voiceKey: "pressure_unit_voice_kpa",
        valueConterver: { (value: Double) -> Double in
            return value * 0.1
        }
    )
    public static let hpa = PressureUnit(
        key: "pressure_unit_hpa",
        voiceKey: "pressure_unit_voice_hpa",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    public static let atm = PressureUnit(
        key: "pressure_unit_atm",
        voiceKey: "pressure_unit_voice_atm",
        valueConterver: { (value: Double) -> Double in
            return value * 0.0009869
        }
    )
    public static let mmhg = PressureUnit(
        key: "pressure_unit_mmhg",
        voiceKey: "pressure_unit_voice_mmhg",
        valueConterver: { (value: Double) -> Double in
            return value * 0.75006
        }
    )
    public static let inhg = PressureUnit(
        key: "pressure_unit_inhg",
        voiceKey: "pressure_unit_voice_inhg",
        valueConterver: { (value: Double) -> Double in
            return value * 0.02953
        }
    )
    public static let kgfpsqcm = PressureUnit(
        key: "pressure_unit_kgfpsqcm",
        voiceKey: "pressure_unit_voice_kgfpsqcm",
        valueConterver: { (value: Double) -> Double in
            return value * 0.00102
        }
    )
    
    public static let all = [mb, kpa, hpa, atm, mmhg, inhg, kgfpsqcm]
    
    public static subscript(index: Int) -> PressureUnit {
        get {
            return PressureUnit.all[index]
        }
    }
    
    public static subscript(key: String) -> PressureUnit {
        get {
            for item in PressureUnit.all {
                if item.key == key {
                    return item
                }
            }
            return PressureUnit.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let valueConterver: ValueConverter<Double>
    
    private init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    public func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    public func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    public func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - precipitation.

public struct PrecipitationUnit: Unit {
    
    public typealias ImplType = PrecipitationUnit
    public typealias ValueType = Double
    
    public static let mm = PrecipitationUnit(
        key: "precipitation_unit_mm",
        voiceKey: "precipitation_unit_voice_mm",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    public static let cm = PrecipitationUnit(
        key: "precipitation_unit_cm",
        voiceKey: "precipitation_unit_voice_cm",
        valueConterver: { (value: Double) -> Double in
            return value * 0.1
        }
    )
    public static let inch = PrecipitationUnit(
        key: "precipitation_unit_in",
        voiceKey: "precipitation_unit_voice_in",
        valueConterver: { (value: Double) -> Double in
            return value * 0.0394
        }
    )
    public static let lpsqm = PrecipitationUnit(
        key: "precipitation_unit_lpsqm",
        voiceKey: "precipitation_unit_voice_lpsqm",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    
    public static let all = [mm, cm, inch, lpsqm]
    
    public static subscript(index: Int) -> PrecipitationUnit {
        get {
            return PrecipitationUnit.all[index]
        }
    }
    
    public static subscript(key: String) -> PrecipitationUnit {
        get {
            for item in PrecipitationUnit.all {
                if item.key == key {
                    return item
                }
            }
            return PrecipitationUnit.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let valueConterver: ValueConverter<Double>
    
    private init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    public func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    public func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    public func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - precipitation intensity.

public struct PrecipitationIntensityUnit: Unit {
    
    public typealias ImplType = PrecipitationIntensityUnit
    public typealias ValueType = Double
    
    public static let mm = PrecipitationIntensityUnit(
        key: "precipitation_intensity_unit_mm",
        voiceKey: "precipitation_intensity_unit_voice_mm",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    public static let cm = PrecipitationIntensityUnit(
        key: "precipitation_intensity_unit_cm",
        voiceKey: "precipitation_intensity_unit_voice_cm",
        valueConterver: { (value: Double) -> Double in
            return value * 0.1
        }
    )
    public static let inch = PrecipitationIntensityUnit(
        key: "precipitation_intensity_unit_in",
        voiceKey: "precipitation_intensity_unit_voice_in",
        valueConterver: { (value: Double) -> Double in
            return value * 0.0394
        }
    )
    public static let lpsqm = PrecipitationIntensityUnit(
        key: "precipitation_intensity_unit_lpsqm",
        voiceKey: "precipitation_intensity_unit_voice_lpsqm",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    
    public static let all = [mm, cm, inch, lpsqm]
    
    public static subscript(index: Int) -> PrecipitationIntensityUnit {
        get {
            return PrecipitationIntensityUnit.all[index]
        }
    }
    
    public static subscript(key: String) -> PrecipitationIntensityUnit {
        get {
            for item in PrecipitationIntensityUnit.all {
                if item.key == key {
                    return item
                }
            }
            return PrecipitationIntensityUnit.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let valueConterver: ValueConverter<Double>
    
    private init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    public func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    public func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    public func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - distance.

public struct DistanceUnit: Unit {
    
    public typealias ImplType = DistanceUnit
    public typealias ValueType = Double
    
    public static let km = DistanceUnit(
        key: "distance_unit_km",
        voiceKey: "distance_unit_voice_km",
        valueConterver: { (value: Double) -> Double in
            return value
        }
    )
    public static let m = DistanceUnit(
        key: "distance_unit_m",
        voiceKey: "distance_unit_voice_m",
        valueConterver: { (value: Double) -> Double in
            return value * 1000
        }
    )
    public static let mi = DistanceUnit(
        key: "distance_unit_mi",
        voiceKey: "distance_unit_voice_mi",
        valueConterver: { (value: Double) -> Double in
            return value * 0.6213
        }
    )
    public static let nmi = DistanceUnit(
        key: "distance_unit_nmi",
        voiceKey: "distance_unit_voice_nmi",
        valueConterver: { (value: Double) -> Double in
            return value * 0.5399
        }
    )
    public static let ft = DistanceUnit(
        key: "distance_unit_ft",
        voiceKey: "distance_unit_voice_ft",
        valueConterver: { (value: Double) -> Double in
            return value * 3280.8398
        }
    )
    
    public static let all = [km, m, mi, nmi, ft]
    
    public static subscript(index: Int) -> DistanceUnit {
        get {
            return DistanceUnit.all[index]
        }
    }
    
    public static subscript(key: String) -> DistanceUnit {
        get {
            for item in DistanceUnit.all {
                if item.key == key {
                    return item
                }
            }
            return DistanceUnit.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let valueConterver: ValueConverter<Double>
    
    private init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    public func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    public func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    public func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}
