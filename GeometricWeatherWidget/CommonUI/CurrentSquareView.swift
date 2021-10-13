//
//  CurrentSquareView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/11.
//

import SwiftUI
import GeometricWeatherBasic

struct CurrentSquareView: View {
    
    let location: Location
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0.0) {
                Text(
                    getLocationText(location: self.location)
                ).font(
                    Font(miniCaptionFont).weight(.semibold)
                ).foregroundColor(
                    .white
                )
                
                Text(
                    self.getTemperatureTitleText()
                ).font(
                    largeTemperatureFont
                ).foregroundColor(
                    .white
                )
                
                Text(
                    self.getBottomCaptionText()
                ).font(
                    Font(miniCaptionFont)
                ).foregroundColor(
                    .white
                ).padding(
                    EdgeInsets(
                        top: 2.0,
                        leading: 6.0,
                        bottom: 2.0,
                        trailing: 6.0
                    )
                ).background(
                    aqiWindBackground.cornerRadius(aqiWindCornerRadius)
                )
                
                Spacer()
                
                HStack(spacing: 4.0) {
                    Text(
                        self.getBottomBodyText()
                    ).font(
                        Font(captionFont)
                    ).foregroundColor(
                        .white
                    )
                    
                    if let uiImage = UIImage.getWeatherIcon(
                        weatherCode: self.location.weather?.current.weatherCode ?? .clear,
                        daylight: self.location.daylight
                    )?.scaleToSize(
                        CGSize(width: miniWeatherIconSize, height: miniWeatherIconSize)
                    ) {
                        Image(uiImage: uiImage)
                    }
                }
            }
            
            Spacer()
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
