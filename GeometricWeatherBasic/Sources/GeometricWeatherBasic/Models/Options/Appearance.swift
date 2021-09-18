//
//  Appearance.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct DarkMode: Option {
    
    public typealias ImplType = DarkMode
    
    public static var all = [
        DarkMode(key: "dark_mode_system"),
        DarkMode(key: "dark_mode_auto"),
        DarkMode(key: "dark_mode_light"),
        DarkMode(key: "dark_mode_dark"),
    ]
    
    public static subscript(index: Int) -> DarkMode {
        get {
            return DarkMode.all[index]
        }
    }
    
    public static subscript(key: String) -> DarkMode {
        get {
            for item in DarkMode.all {
                if item.key == key {
                    return item
                }
            }
            return DarkMode.all[0]
        }
    }
    
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
}
