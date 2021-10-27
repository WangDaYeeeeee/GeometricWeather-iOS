//
//  File.swift
//  
//
//  Created by 王大爷 on 2021/10/25.
//

import Foundation

public struct Minutely: Codable {
    
    // local time.
    public let beginTime: TimeInterval
    public let endTime: TimeInterval
    
    public let precipitationIntensityInPercentage: [Double]
    
    public init(
        beginTime: TimeInterval,
        endTime: TimeInterval,
        precipitationIntensityInPercentage: [Double]
    ) {
        self.beginTime = beginTime
        self.endTime = endTime
        self.precipitationIntensityInPercentage = precipitationIntensityInPercentage
    }
}
