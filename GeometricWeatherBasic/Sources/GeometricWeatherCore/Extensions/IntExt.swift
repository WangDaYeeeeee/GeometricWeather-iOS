//
//  IntExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation

public extension Int {
    
    static func toInt(_ value: Double?) -> Int? {
        if let v = value {
            return Int(v)
        }
        
        return nil
    }
}
