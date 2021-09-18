//
//  File.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct UV: Codable {
    
    public let index: Int?
    public let level: String?
    public let description: String?

    public static let uvIndexLevelLow = 2
    public static let uvIndexLevelMiddle = 5
    public static let uvIndexLevelHigh = 7
    public static let uvIndexLevelExcessive = 10
    
    public init(index: Int?, level: String?, description: String?) {
        self.index = index
        self.level = level
        self.description = description
    }
    
    public func isValid() -> Bool {
        return index != nil || level != nil || description != nil
    }
    
    public func getUVDescription() -> String {
        var str = ""
        
        if (index != nil) {
            str += "\(index!)"
        }
        if (level != nil && level != "") {
            str += " \(level!)"
        }
        if (description != nil && description != "") {
            str += " \(description!)"
        }
        
        return str
    }

    public func getShortUVDescription() -> String {
        var str = ""
        
        if (index != nil) {
            str += "\(index!)"
        }
        if (level != nil && level != "") {
            str += " \(level!)"
        }
        
        return str
    }

    public func getUVLevel() -> Int {
        if (index == nil) {
            return 1
        } else if (index! <= Self.uvIndexLevelLow) {
            return 1
        } else if (index! <= Self.uvIndexLevelMiddle) {
            return 2
        } else if (index! <= Self.uvIndexLevelHigh) {
            return 3
        } else if (index! <= Self.uvIndexLevelExcessive) {
            return 4
        } else {
            return 5
        }
    }
}
