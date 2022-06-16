//
//  MainModel.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct CurrentLocation: Equatable {
    
    let location: Location
    let daylight: Bool
    
    init(_ location: Location) {
        self.location = location
        self.daylight = isDaylight(location: location)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.location == rhs.location && lhs.daylight == rhs.daylight
    }
}

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

enum MainToastMessage {
    
    case backgroundUpdate
    case locationFailed
    case weatherRequestFailed
}
