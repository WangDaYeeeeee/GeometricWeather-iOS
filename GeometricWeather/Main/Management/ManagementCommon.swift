//
//  ManagementCommon.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/10.
//

import Foundation
import GeometricWeatherBasic

struct LocationItem {
    let location: Location
    let selected: Bool
}

struct HideKeyboardEvent {
    // nothing.
}
struct AddLocationEvent {
    
    let location: Location
}
