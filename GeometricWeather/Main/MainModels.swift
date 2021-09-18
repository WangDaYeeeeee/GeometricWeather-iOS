//
//  MainModel.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import Foundation
import GeometricWeatherBasic

struct Indicator: Equatable {
    
    let total: Int
    let index: Int
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.total == rhs.total && lhs.index == rhs.index
    }
}

struct SelectableLocationArray {
    
    var locations: [Location] // valid locations.
    let selectedId: String?
}
