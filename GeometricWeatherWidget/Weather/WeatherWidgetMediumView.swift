//
//  WeatherWidgetMediumView.swift
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

struct WeatherWidgetMediumView: View {
    
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            WeatherWidgetMediumHeaderView(
                location: self.location
            ).padding(
                [.top, .leading, .trailing]
            )
            
            Spacer()
            
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

struct WeatherWidgetMediumHeaderView: View {
    
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            LocationTextView(
                locationText: getLocationText(location: self.location),
                isCurrentLocation: self.location.currentPosition
            )
            
            HStack(alignment: .center) {
                Text(
                    self.getTemperatureTitleText()
                ).font(
                    largeTemperatureFont
                ).foregroundColor(
                    .white
                )
                
                if let weather = self.location.weather {
                    VStack(alignment: .trailing, spacing: 2.0) {
                        Text(
                            SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                                weather.dailyForecasts[0].day.temperature.temperature,
                                unit: "°"
                            )
                        ).font(Font(miniCaptionFont).weight(.bold))
                            .foregroundColor(.white)
                        
                        Text(
                            SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                                weather.dailyForecasts[0].night.temperature.temperature,
                                unit: "°"
                            )
                        ).font(Font(miniCaptionFont).weight(.bold))
                            .foregroundColor(.white)
                            .opacity(secondaryTextOpacity)
                    }.offset(x: -4.0, y: 0.0)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2.0) {
                    Text(self.getBottomBodyText())
                        .font(Font(captionFont).weight(.bold))
                        .foregroundColor(.white)
                    
                    Text(self.getBottomCaptionText())
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
                
                UIImage.getWeatherIcon(
                    weatherCode: self.location.weather?.current.weatherCode ?? .clear,
                    daylight: self.location.isDaylight
                )?.resize(
                    to: CGSize(width: largeWeatherIconSize, height: largeWeatherIconSize)
                )?.toImage()
            }
        }
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

struct WeatherWidgetMediumView_Previews: PreviewProvider {
    
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
            WidgetPreviewContext(family: .systemMedium)
        )
    }
}
