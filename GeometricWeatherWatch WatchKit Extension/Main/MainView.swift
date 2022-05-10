//
//  MainView.swift
//  GeometricWeatherWatch WatchKit Extension
//
//  Created by 王大爷 on 2022/5/2.
//

import SwiftUI
import GeometricWeatherCore

struct MainView: View {
    
    let location: Location
    
    var body: some View {
        VStack {
            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            location: Location.buildDefaultLocation(
                weatherSource: WeatherSource[0],
                residentPosition: false
            )
        )
    }
}
