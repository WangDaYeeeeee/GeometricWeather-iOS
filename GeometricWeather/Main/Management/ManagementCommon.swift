//
//  ManagementCommon.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/10.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct LocationItem: Hashable {
    
    let location: Location
    let selected: Bool
    
    func hash(into hasher: inout Hasher) {
        return location.formattedId.hash(into: &hasher)
    }
}

struct HideKeyboardEvent {
    // nothing.
}
struct AddLocationEvent {
    
    let location: Location
}
