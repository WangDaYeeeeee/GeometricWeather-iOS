//
//  File.swift
//  
//
//  Created by 王大爷 on 2021/10/11.
//

import Foundation

public extension Date {
    
    static func now(in timezone: TimeZone) -> Date {
        return Date(
            timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
                timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            )
        )
    }
    
    func isToday() -> Bool{
        let nowComps = Calendar.current.dateComponents(
            [.day,.month,.year],
            from: Date()
        )
        let selfCmps = Calendar.current.dateComponents(
            [.day,.month,.year],
            from: self
        )
        
        return selfCmps.year == nowComps.year
        && selfCmps.month == nowComps.month
        && selfCmps.day == nowComps.day
    }
    
    func getTimeIntervalByYearMonthDay() -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selfStr = formatter.string(from: self)
        let result = formatter.date(from: selfStr)!
        return result.timeIntervalSinceReferenceDate + 24 * 60 * 60
    }
}
