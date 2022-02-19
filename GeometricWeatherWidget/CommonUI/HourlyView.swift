//
//  HourlyView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import SwiftUI
import GeometricWeatherBasic

struct HourlyView: View {
    
    let location: Location
    
    let itemCount = 6
    
    var body: some View {
        HStack(alignment: .center) {
            ForEach(0 ..< self.itemCount) { i in
                if let weather = self.location.weather {
                    HourlyItemView(
                        weather: weather,
                        timezone: self.location.timezone,
                        index: i / 2
                    )
                } else {
                    Text(
                        "--"
                    ).font(
                        Font(miniCaptionFont)
                    ).foregroundColor(
                        .white
                    )
                }
            }
        }
    }
}
