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
    
    // compatible for legacy json coding!!!!!!!!!!!!!!!!!!!
    public let precipitationIntensityInPercentage: [Double]
    public var precipitationIntensities: [Double] {
        get {
            return self.precipitationIntensityInPercentage
        }
    }
    
    public init(
        beginTime: TimeInterval,
        endTime: TimeInterval,
        precipitationIntensities: [Double]
    ) {
        self.beginTime = beginTime
        self.endTime = endTime
        self.precipitationIntensityInPercentage = precipitationIntensities
    }
}
