//
//  Temperature.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct Temperature: Codable {
    
    let temperature: Int
    let realFeelTemperature: Int?
    let realFeelShaderTemperature: Int?
    let apparentTemperature: Int?
    let windChillTemperature: Int?
    let wetBulbTemperature: Int?
    let degreeDayTemperature: Int?
    
    init(
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

    func isValid() -> Bool {
        return realFeelTemperature != nil
                || realFeelShaderTemperature != nil
                || apparentTemperature != nil
                || windChillTemperature != nil
                || wetBulbTemperature != nil
                || degreeDayTemperature != nil
    }
}
