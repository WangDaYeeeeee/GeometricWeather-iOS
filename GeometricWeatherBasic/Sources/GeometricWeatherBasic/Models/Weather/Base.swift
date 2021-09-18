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
    
    public let publishTime: TimeInterval
    public let updateTime: TimeInterval
    
    public init(
        cityId: String,
        timeStamp: TimeInterval,
        publishTime: TimeInterval,
        updateTime: TimeInterval
    ) {
        self.cityId = cityId
        self.timeStamp = timeStamp
        self.publishTime = publishTime
        self.updateTime = updateTime
    }
    
    public func formatePublishTime(twelveHour: Bool) -> String {
        return formateTime(
            timeIntervalSine1970: publishTime,
            twelveHour: twelveHour
        )
    }
    
    public func formateUpdateTime(twelveHour: Bool) -> String {
        return formateTime(
            timeIntervalSine1970: updateTime,
            twelveHour: twelveHour
        )
    }
}
