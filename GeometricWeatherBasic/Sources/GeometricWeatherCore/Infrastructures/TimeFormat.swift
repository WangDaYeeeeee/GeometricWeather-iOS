//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/5/4.
//

import Foundation

public func formateTime(
    timeIntervalSine1970: TimeInterval,
    twelveHour: Bool,
    timezone: TimeZone = TimeZone.current
) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = twelveHour ? "h:mm aa" : "HH:mm"
    
    return formatter.string(
        from: Date(
            timeIntervalSince1970: timeIntervalSine1970 + Double(
                timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            )
        )
    )
}

public func isTwelveHour() -> Bool {
    if let formatter = DateFormatter.dateFormat(
        fromTemplate: "j",
        options: 0,
        locale: NSLocale.current
    ) {
        return formatter.contains("a")
    } else {
        return false
    }
}
