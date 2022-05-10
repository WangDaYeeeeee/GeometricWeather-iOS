//
//  HourlyView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import SwiftUI
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherResources

private let itemCount = 6

struct HourlyView: View {
    
    let location: Location
    
    var body: some View {
        if let weather = self.location.weather {
            HStack(alignment: .center) {
                ForEach(0 ..< itemCount, id: \.self) { i in
                    HourlyItemView(
                        weather: weather,
                        timezone: self.location.timezone,
                        index: i / 2
                    )
                }
            }
        } else {
            Color.clear
        }
    }
}

struct HourlyView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HStack {
                ForEach(0 ..< itemCount, id: \.self) { i in
                    HourlyItemView(
                        hourText: "hour1",
                        weatherCode: .clear,
                        daylight: false,
                        temperature: 6
                    )
                }
            }
            Spacer()
        }.background(
            Color.cyan
        ).previewContext(
            WidgetPreviewContext(family: .systemMedium)
        )
    }
}
