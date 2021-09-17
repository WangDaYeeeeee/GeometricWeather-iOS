//
//  Base.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

struct Base: Codable {
    
    let cityId: String
    let timeStamp: TimeInterval
    
    let publishTime: TimeInterval
    let updateTime: TimeInterval
    
    init(
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
    
    func formatePublishTime(twelveHour: Bool) -> String {
        return formateTime(
            timeIntervalSine1970: publishTime,
            twelveHour: twelveHour
        )
    }
    
    func formateUpdateTime(twelveHour: Bool) -> String {
        return formateTime(
            timeIntervalSine1970: updateTime,
            twelveHour: twelveHour
        )
    }
}
