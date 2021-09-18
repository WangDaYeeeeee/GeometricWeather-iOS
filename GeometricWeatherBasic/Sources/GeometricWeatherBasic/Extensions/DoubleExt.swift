//
//  DoubleExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public extension Double {
    
    static func toDouble(_ value: Int?) -> Double? {
        if let v = value {
            return Double(v)
        }
        
        return nil
    }
    
    func toString(_ decimal: Int) -> String {
        let truncated = trunc(self * 10) / 10
        return String(format: "%.1f", truncated)
    }
}
