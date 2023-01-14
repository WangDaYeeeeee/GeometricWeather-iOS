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

struct LocationItem: Diffable, Hashable {
    
    let location: Location
    let selected: Bool
    
    var identifier: String {
        self.location.formattedId
        + String(self.location.weather?.base.timeStamp ?? 0)
        + (self.selected ? "selected" : "unselected")
        + (self.location.residentPosition ? "resident" : "unresident")
    }
    
    let obj = NSObject()
    
    func hash(into hasher: inout Hasher) {
        return self.identifier.hash(into: &hasher)
    }
}

struct HideKeyboardEvent {
    // nothing.
}
struct AddLocationEvent {
    
    let location: Location
}
