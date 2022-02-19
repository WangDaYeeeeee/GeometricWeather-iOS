//
//  WeatherWidgetLargeView.swift
//  WeatherWidgetExtension
//
//  Created by 王大爷 on 2021/9/19.
//

import WidgetKit
import SwiftUI
import GeometricWeatherBasic

// MARK: - view.

struct WeatherWidgetLargeView: View {
    
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            WeatherWidgetMediumHeaderView(
                location: self.location
            ).padding(
                [.top, .leading, .trailing]
            )
            
            if !(self.location.weather?.alerts.isEmpty ?? true) {
                Color.white.opacity(0.0).frame(width: 1.0, height: 4.0, alignment: .center)
                Text(
                    self.location.weather!.alerts[0].description
                ).font(
                    Font(miniCaptionFont)
                ).foregroundColor(
                    .white
                ).padding(
                    [.leading, .trailing]
                )
                Color.white.opacity(0.0).frame(width: 1.0, height: 4.0, alignment: .center)
            }
            
            Color.white.opacity(0.0).frame(width: 1.0, height: 12.0, alignment: .center)
            DailyView(
                location: self.location
            ).padding(
                EdgeInsets(
                    top: 0,
                    leading: littleMargin,
                    bottom: 0,
                    trailing: littleMargin
                )
            )
            
            Color.white.opacity(0.0).frame(width: 1.0, height: 18.0, alignment: .center)
            HourlyView(
                location: self.location
            ).padding(
                EdgeInsets(
                    top: 0,
                    leading: littleMargin,
                    bottom: littleMargin,
                    trailing: littleMargin
                )
            )
        }
    }
}

// MARK: - preview.

struct WeatherWidgetLargeView_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Color.black
            
            WeatherWidgetLargeView(
                location: .buildDefaultLocation(
                    weatherSource: WeatherSource[0],
                    residentPosition: false
                )
            )
        }.previewContext(
            WidgetPreviewContext(family: .systemLarge)
        )
    }
}
