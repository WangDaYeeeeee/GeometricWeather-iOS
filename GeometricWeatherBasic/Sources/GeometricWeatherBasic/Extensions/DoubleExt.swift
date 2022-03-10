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
        if self.isZero {
            return "0"
        }
        
        let truncated = trunc(self * 10) / 10
        var str = String(format: "%.\(decimal)f", truncated)
        
        if (Double(str) ?? 0) > 0 {
            return str
        }
        
        str = "<0"
        if decimal > 0 {
            str += "."
        }
        for _ in 0 ..< (decimal - 1) {
            str += "0"
        }
        str += "1"
        return str
    }
    
    func keepIn(range: ClosedRange<Double>) -> Double {
        if self < range.lowerBound {
            return range.lowerBound
        }
        if self > range.upperBound {
            return range.upperBound
        }
        return self
    }
}
