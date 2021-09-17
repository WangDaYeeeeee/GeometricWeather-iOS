//
//  Widget.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct WidgetDailyIconStyle: Option {
    
    typealias ImplType = WidgetDailyIconStyle
    
    static let all = [
        WidgetDailyIconStyle(key: "widget_week_icon_mode_auto"),
        WidgetDailyIconStyle(key: "widget_week_icon_mode_daytime"),
        WidgetDailyIconStyle(key: "widget_week_icon_mode_nighttime"),
    ]
    
    static subscript(index: Int) -> WidgetDailyIconStyle {
        get {
            return WidgetDailyIconStyle.all[index]
        }
    }
    
    static subscript(key: String) -> WidgetDailyIconStyle {
        get {
            for item in WidgetDailyIconStyle.all {
                if item.key == key {
                    return item
                }
            }
            return WidgetDailyIconStyle.all[0]
        }
    }
    
    let key: String
    
    init(key: String) {
        self.key = key
    }
}
