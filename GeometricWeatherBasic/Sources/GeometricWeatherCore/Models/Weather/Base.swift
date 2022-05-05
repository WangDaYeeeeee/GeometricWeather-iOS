//
//  Base.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

public struct Base: Codable {
    
    public let cityId: String
    public let timeStamp: TimeInterval
    
    public init(
        cityId: String,
        timeStamp: TimeInterval
    ) {
        self.cityId = cityId
        self.timeStamp = timeStamp
    }
    
    public func formatePublishTime(twelveHour: Bool) -> String {
        return formateTime(
            timeIntervalSine1970: self.timeStamp,
            twelveHour: twelveHour
        )
    }
}
