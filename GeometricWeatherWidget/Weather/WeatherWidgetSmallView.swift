//
//  WeatherWidgetSmallView.swift
//  WeatherWidgetExtension
//
//  Created by 王大爷 on 2021/9/19.
//

import WidgetKit
import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings

// MARK: - view.

struct WeatherWidgetSmallView: View {
    
    let location: Location
    
    var body: some View {
        HStack {
            CurrentSquareView(location: self.location)
            Spacer()
        }.padding()
    }
    
    private func getTemperatureTitleText() -> String {
        if let weather = self.location.weather {
            return SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                weather.current.temperature.temperature,
                unit: "°"
            )
        }
        return "--"
    }
    
    private func getBottomBodyText() -> String {
        if let weather = location.weather {
            return weather.current.weatherText
        }
        return "--"
    }
    
    private func getBottomCaptionText() -> String {
        if let weather = location.weather {
            return weather.current.airQuality.isValid() ? getAirQualityText(
                level: weather.current.airQuality.aqiLevel ?? 0
            ) : getShortWindText(wind: weather.current.wind)
        }
        return "----"
    }
}

// MARK: - preview.

struct WeatherWidgetSmallView_Previews: PreviewProvider {
        
    static var previews: some View {
        ZStack {
            Color.black
            
            WeatherWidgetSmallView(
                location: .buildDefaultLocation(
                    weatherSource: WeatherSource[0],
                    residentPosition: false
                )
            )
        }.previewContext(
            WidgetPreviewContext(family: .systemSmall)
        )
    }
}
