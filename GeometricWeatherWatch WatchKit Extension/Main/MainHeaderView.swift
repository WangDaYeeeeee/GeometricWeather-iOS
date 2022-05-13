//
//  MainHeaderView.swift
//  GeometricWeatherWatch WatchKit Extension
//
//  Created by 王大爷 on 2022/5/10.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings

struct MainHeaderView: View {
    
    let currentTemperature: Int
    let currentWeatherCode: WeatherCode
    let currentDaylight: Bool
    let currentWeatherText: String
    let currentSubtitle: String
    
    let screenSize: CGSize
    
    var body: some View {
        VStack {
            HStack(spacing: littleMargin) {
                Text(
                    SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                        self.currentTemperature,
                        unit: "º"
                    )
                ).font(.system(size: 52.0, weight: .regular, design: .default))
                
                Image.getWeatherIcon(
                    weatherCode: self.currentWeatherCode,
                    daylight: self.currentDaylight
                )?.resizable()
                    .frame(width: 42, height: 42)
            }
            
            Text(self.currentWeatherText)
                .font(Font(largeTitleFont))
            Text(self.currentSubtitle)
                .font(Font(miniCaptionFont))
                .opacity(0.5)
        }.frame(width: self.screenSize.width, height: self.screenSize.height)
    }
}

struct MainHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            MainHeaderView(
                currentTemperature: 56,
                currentWeatherCode: .clear,
                currentDaylight: true,
                currentWeatherText: "Clear",
                currentSubtitle: "Middle pollution",
                screenSize: proxy.size
            )
        }
    }
}
