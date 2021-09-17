//
//  Appearance.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct DarkMode: Option {
    
    typealias ImplType = DarkMode
    
    static var all = [
        DarkMode(key: "dark_mode_system"),
        DarkMode(key: "dark_mode_auto"),
        DarkMode(key: "dark_mode_light"),
        DarkMode(key: "dark_mode_dark"),
    ]
    
    static subscript(index: Int) -> DarkMode {
        get {
            return DarkMode.all[index]
        }
    }
    
    static subscript(key: String) -> DarkMode {
        get {
            for item in DarkMode.all {
                if item.key == key {
                    return item
                }
            }
            return DarkMode.all[0]
        }
    }
    
    let key: String
    
    init(key: String) {
        self.key = key
    }
}
