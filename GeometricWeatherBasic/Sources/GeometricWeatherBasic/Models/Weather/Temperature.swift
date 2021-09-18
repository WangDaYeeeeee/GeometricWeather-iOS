//
//  Temperature.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct Temperature: Codable {
    
    public let temperature: Int
    public let realFeelTemperature: Int?
    public let realFeelShaderTemperature: Int?
    public let apparentTemperature: Int?
    public let windChillTemperature: Int?
    public let wetBulbTemperature: Int?
    public let degreeDayTemperature: Int?
    
    public init(
        temperature: Int,
        realFeelTemperature: Int? = nil,
        realFeelShaderTemperature: Int? = nil,
        apparentTemperature: Int? = nil,
        windChillTemperature: Int? = nil,
        wetBulbTemperature: Int? = nil,
        degreeDayTemperature: Int? = nil
    ) {
        self.temperature = temperature
        self.realFeelTemperature = realFeelTemperature
        self.realFeelShaderTemperature = realFeelShaderTemperature
        self.apparentTemperature = apparentTemperature
        self.windChillTemperature = windChillTemperature
        self.wetBulbTemperature = wetBulbTemperature
        self.degreeDayTemperature = degreeDayTemperature
    }

    public func isValid() -> Bool {
        return realFeelTemperature != nil
                || realFeelShaderTemperature != nil
                || apparentTemperature != nil
                || windChillTemperature != nil
                || wetBulbTemperature != nil
                || degreeDayTemperature != nil
    }
}
