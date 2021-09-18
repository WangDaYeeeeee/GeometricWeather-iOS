//
//  Widget.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct WidgetDailyIconStyle: Option {
    
    public typealias ImplType = WidgetDailyIconStyle
    
    public static let all = [
        WidgetDailyIconStyle(key: "widget_week_icon_mode_auto"),
        WidgetDailyIconStyle(key: "widget_week_icon_mode_daytime"),
        WidgetDailyIconStyle(key: "widget_week_icon_mode_nighttime"),
    ]
    
    public static subscript(index: Int) -> WidgetDailyIconStyle {
        get {
            return WidgetDailyIconStyle.all[index]
        }
    }
    
    public static subscript(key: String) -> WidgetDailyIconStyle {
        get {
            for item in WidgetDailyIconStyle.all {
                if item.key == key {
                    return item
                }
            }
            return WidgetDailyIconStyle.all[0]
        }
    }
    
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
}
