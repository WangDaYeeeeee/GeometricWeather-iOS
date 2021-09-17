//
//  Units.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

// MARK: - temperature.
struct TemperatureUnit: Unit {
    
    typealias ImplType = TemperatureUnit
    typealias ValueType = Int
    
    static let all = [
        TemperatureUnit(
            key: "temperature_unit_c",
            voiceKey: "temperature_unit_voice_c",
            valueConterver: { (value: Int) -> Int in
                return value
            }
        ),
        TemperatureUnit(
            key: "temperature_unit_f",
            voiceKey: "temperature_unit_voice_f",
            valueConterver: { (value: Int) -> Int in
                return Int(32 + 1.8 * Double(value))
            }
        ),
        TemperatureUnit(
            key: "temperature_unit_k",
            voiceKey: "temperature_unit_voice_k",
            valueConterver: { (value: Int) -> Int in
                return Int(273.15 + Double(value))
            }
        )
    ]
    
    static subscript(index: Int) -> TemperatureUnit {
        get {
            return TemperatureUnit.all[index]
        }
    }
    
    static subscript(key: String) -> TemperatureUnit {
        get {
            for item in TemperatureUnit.all {
                if item.key == key {
                    return item
                }
            }
            return TemperatureUnit.all[0]
        }
    }
    
    let key: String
    let voiceKey: String
    let valueConterver: ValueConverter<Int>
    
    init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Int>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    func getValue(_ valueInDefaultType: Int) -> Int {
        return valueConterver(valueInDefaultType)
    }
    
    func formatValue(_ valueInDefaultType: Int) -> String {
        return String(getValue(valueInDefaultType))
    }
    
    func formatValueWithUnit(_ valueInDefaultType: Int, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - speed.
struct SpeedUnit: Unit {
    
    typealias ImplType = SpeedUnit
    typealias ValueType = Double
    
    static let all = [
        SpeedUnit(
            key: "speed_unit_kph",
            voiceKey: "speed_unit_voice_kph",
            valueConterver: { (value: Double) -> Double in
                return value
            }
        ),
        SpeedUnit(
            key: "speed_unit_mps",
            voiceKey: "speed_unit_voice_mps",
            valueConterver: { (value: Double) -> Double in
                return value / 3.6
            }
        ),
        SpeedUnit(
            key: "speed_unit_kn",
            voiceKey: "speed_unit_voice_kn",
            valueConterver: { (value: Double) -> Double in
                return value / 1.852
            }
        ),
        SpeedUnit(
            key: "speed_unit_mph",
            voiceKey: "speed_unit_voice_mph",
            valueConterver: { (value: Double) -> Double in
                return value / 1.609
            }
        ),
        SpeedUnit(
            key: "speed_unit_ftps",
            voiceKey: "speed_unit_voice_ftps",
            valueConterver: { (value: Double) -> Double in
                return value * 0.9113
            }
        )
    ]
    
    static subscript(index: Int) -> SpeedUnit {
        get {
            return SpeedUnit.all[index]
        }
    }
    
    static subscript(key: String) -> SpeedUnit {
        get {
            for item in SpeedUnit.all {
                if item.key == key {
                    return item
                }
            }
            return SpeedUnit.all[0]
        }
    }
    
    let key: String
    let voiceKey: String
    let valueConterver: ValueConverter<Double>
    
    init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - pressure.
struct PressureUnit: Unit {
    
    typealias ImplType = PressureUnit
    typealias ValueType = Double
    
    static let all = [
        PressureUnit(
            key: "pressure_unit_mb",
            voiceKey: "pressure_unit_voice_mb",
            valueConterver: { (value: Double) -> Double in
                return value
            }
        ),
        PressureUnit(
            key: "pressure_unit_kpa",
            voiceKey: "pressure_unit_voice_kpa",
            valueConterver: { (value: Double) -> Double in
                return value * 0.1
            }
        ),
        PressureUnit(
            key: "pressure_unit_hpa",
            voiceKey: "pressure_unit_voice_hpa",
            valueConterver: { (value: Double) -> Double in
                return value
            }
        ),
        PressureUnit(
            key: "pressure_unit_atm",
            voiceKey: "pressure_unit_voice_atm",
            valueConterver: { (value: Double) -> Double in
                return value * 0.0009869
            }
        ),
        PressureUnit(
            key: "pressure_unit_mmhg",
            voiceKey: "pressure_unit_voice_mmhg",
            valueConterver: { (value: Double) -> Double in
                return value * 0.75006
            }
        ),
        PressureUnit(
            key: "pressure_unit_inhg",
            voiceKey: "pressure_unit_voice_inhg",
            valueConterver: { (value: Double) -> Double in
                return value * 0.02953
            }
        ),
        PressureUnit(
            key: "pressure_unit_kgfpsqcm",
            voiceKey: "pressure_unit_voice_kgfpsqcm",
            valueConterver: { (value: Double) -> Double in
                return value * 0.00102
            }
        )
    ]
    
    static subscript(index: Int) -> PressureUnit {
        get {
            return PressureUnit.all[index]
        }
    }
    
    static subscript(key: String) -> PressureUnit {
        get {
            for item in PressureUnit.all {
                if item.key == key {
                    return item
                }
            }
            return PressureUnit.all[0]
        }
    }
    
    let key: String
    let voiceKey: String
    let valueConterver: ValueConverter<Double>
    
    init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(2)
    }
    
    func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - precipitation.
struct PrecipitationUnit: Unit {
    
    typealias ImplType = PrecipitationUnit
    typealias ValueType = Double
    
    static let all = [
        PrecipitationUnit(
            key: "precipitation_unit_mm",
            voiceKey: "precipitation_unit_voice_mm",
            valueConterver: { (value: Double) -> Double in
                return value
            }
        ),
        PrecipitationUnit(
            key: "precipitation_unit_cm",
            voiceKey: "precipitation_unit_voice_cm",
            valueConterver: { (value: Double) -> Double in
                return value * 0.1
            }
        ),
        PrecipitationUnit(
            key: "precipitation_unit_in",
            voiceKey: "precipitation_unit_voice_in",
            valueConterver: { (value: Double) -> Double in
                return value * 0.0394
            }
        ),
        PrecipitationUnit(
            key: "precipitation_unit_lpsqm",
            voiceKey: "precipitation_unit_voice_lpsqm",
            valueConterver: { (value: Double) -> Double in
                return value
            }
        ),
    ]
    
    static subscript(index: Int) -> PrecipitationUnit {
        get {
            return PrecipitationUnit.all[index]
        }
    }
    
    static subscript(key: String) -> PrecipitationUnit {
        get {
            for item in PrecipitationUnit.all {
                if item.key == key {
                    return item
                }
            }
            return PrecipitationUnit.all[0]
        }
    }
    
    let key: String
    let voiceKey: String
    let valueConterver: ValueConverter<Double>
    
    init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}

// MARK: - distance.
struct DistanceUnit: Unit {
    
    typealias ImplType = DistanceUnit
    typealias ValueType = Double
    
    static let all = [
        DistanceUnit(
            key: "distance_unit_km",
            voiceKey: "distance_unit_voice_km",
            valueConterver: { (value: Double) -> Double in
                return value
            }
        ),
        DistanceUnit(
            key: "distance_unit_m",
            voiceKey: "distance_unit_voice_m",
            valueConterver: { (value: Double) -> Double in
                return value * 1000
            }
        ),
        DistanceUnit(
            key: "distance_unit_mi",
            voiceKey: "distance_unit_voice_mi",
            valueConterver: { (value: Double) -> Double in
                return value * 0.6213
            }
        ),
        DistanceUnit(
            key: "distance_unit_nmi",
            voiceKey: "distance_unit_voice_nmi",
            valueConterver: { (value: Double) -> Double in
                return value * 0.5399
            }
        ),
        DistanceUnit(
            key: "distance_unit_ft",
            voiceKey: "distance_unit_voice_ft",
            valueConterver: { (value: Double) -> Double in
                return value * 3280.8398
            }
        ),
    ]
    
    static subscript(index: Int) -> DistanceUnit {
        get {
            return DistanceUnit.all[index]
        }
    }
    
    static subscript(key: String) -> DistanceUnit {
        get {
            for item in DistanceUnit.all {
                if item.key == key {
                    return item
                }
            }
            return DistanceUnit.all[0]
        }
    }
    
    let key: String
    let voiceKey: String
    let valueConterver: ValueConverter<Double>
    
    init(
        key: String,
        voiceKey: String,
        valueConterver: @escaping ValueConverter<Double>
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.valueConterver = valueConterver
    }
    
    func getValue(_ valueInDefaultType: Double) -> Double {
        return valueConterver(valueInDefaultType)
    }
    
    func formatValue(_ valueInDefaultType: Double) -> String {
        return getValue(valueInDefaultType).toString(1)
    }
    
    func formatValueWithUnit(_ valueInDefaultType: Double, unit: String) -> String {
        return "\(formatValue(valueInDefaultType))\(unit)"
    }
}
