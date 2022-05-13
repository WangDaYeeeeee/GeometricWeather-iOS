//
//  CurrentSquareView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/11.
//

import SwiftUI
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherTheme

struct CurrentSquareView: View {
    
    let locationText: String
    let currentTemperature: Int
    let subtitle: String
    
    let currentWeatherCode: WeatherCode
    let currentDaylight: Bool
    let currentWeatherText: String
    
    init(
        locationText: String,
        currentTemperature: Int,
        subtitle: String,
        currentWeatherCode: WeatherCode,
        currentDaylight: Bool,
        currentWeatherText: String
    ) {
        self.locationText = locationText
        self.currentTemperature = currentTemperature
        self.subtitle = subtitle
        self.currentWeatherCode = currentWeatherCode
        self.currentDaylight = currentDaylight
        self.currentWeatherText = currentWeatherText
    }
    
    init(location: Location) {
        self.locationText = getLocationText(location: location)
        self.currentTemperature = location.weather?.current.temperature.temperature ?? 0
        
        if let weather = location.weather {
            self.subtitle = weather.current.airQuality.isValid()
            ? getAirQualityText(level: weather.current.airQuality.aqiLevel ?? 0)
            : getShortWindText(wind: weather.current.wind)
        } else {
            self.subtitle = ""
        }
        
        self.currentWeatherCode = location.weather?.current.weatherCode ?? .clear
        self.currentDaylight = location.isDaylight
        self.currentWeatherText = location.weather?.current.weatherText ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Text(self.locationText)
                .font(Font(miniCaptionFont).weight(.semibold))
                .foregroundColor(.white)
            
            HStack(alignment: .center, spacing: 0) {
                Text(
                    SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                        self.currentTemperature,
                        unit: "°"
                    )
                ).font(largeTemperatureFont)
                    .foregroundColor(.white)
            }
            
            if !self.subtitle.replacingOccurrences(of: " ", with: "").isEmpty {
                Text(self.subtitle)
                    .font(Font(miniCaptionFont))
                    .foregroundColor(.white)
                    .padding(
                        EdgeInsets(
                            top: 2.0,
                            leading: 6.0,
                            bottom: 2.0,
                            trailing: 6.0
                        )
                    )
                    .background(aqiWindBackground.cornerRadius(aqiWindCornerRadius))
            }
            
            Spacer()
            
            HStack(spacing: 4.0) {
                Image.getWeatherIcon(
                    weatherCode: self.currentWeatherCode,
                    daylight: self.currentDaylight
                )?.resizable().frame(
                    width: miniWeatherIconSize,
                    height: miniWeatherIconSize
                )
                
                Text(self.currentWeatherText)
                    .font(Font(captionFont).weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
    }
}

struct CurrentSquareView_Previews: PreviewProvider {
        
    static var previews: some View {
        HStack {
            CurrentSquareView(
                locationText: "Beijing",
                currentTemperature: -99,
                subtitle: "Clear",
                currentWeatherCode: .clear,
                currentDaylight: true,
                currentWeatherText: "Clear"
            )
            Spacer()
        }.padding(
            [.all]
        ).background(
            ThemeManager.weatherThemeDelegate.getWidgetBackgroundView(
                weatherKind: .clear,
                daylight: true
            )
        ).previewContext(
            WidgetPreviewContext(family: .systemSmall)
        )
    }
}

