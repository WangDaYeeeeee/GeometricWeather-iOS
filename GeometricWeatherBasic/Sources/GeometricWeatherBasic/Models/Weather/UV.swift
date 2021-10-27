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
        } else if (index! <= uvIndexLevelLow) {
            return 1
        } else if (index! <= uvIndexLevelMiddle) {
            return 2
        } else if (index! <= uvIndexLevelHigh) {
            return 3
        } else if (index! <= uvIndexLevelExcessive) {
            return 4
        } else {
            return 5
        }
    }
}
