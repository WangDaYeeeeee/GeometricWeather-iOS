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
    
    var body: some View {
        HStack(alignment: .center) {
            // show 6 hourly items.
            ForEach(0 ..< 2 * 6 - 1) { i in
                if i % 2 != 0 {
                    Spacer()
                } else if let weather = self.location.weather {
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
