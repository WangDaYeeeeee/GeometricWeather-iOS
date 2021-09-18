//
//  ResourceManager.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/14.
//

import Foundation
import UIKit

private let sfSunColor = UIColor { traitCollection in
    if traitCollection.userInterfaceStyle == .light {
        return .colorFromRGB(0xffd500)
    } else {
        return .colorFromRGB(0xfecc67)
    }
}

private let sfMoonColor = UIColor { traitCollection in
    if traitCollection.userInterfaceStyle == .light {
        return .colorFromRGB(0xf4faff)
    } else {
        return .colorFromRGB(0xdbf1ff)
    }
}

private let sfCloudColor = UIColor { traitCollection in
    if traitCollection.userInterfaceStyle == .light {
        return .colorFromRGB(0xf9fbfe)
    } else {
        return .colorFromRGB(0xF0F5FD)
    }
}

private let sfSnowColor = UIColor { traitCollection in
    if traitCollection.userInterfaceStyle == .light {
        return .colorFromRGB(0xdfe7ec)
    } else {
        return .colorFromRGB(0xBFCFDA)
    }
}

// MARK: - ui image ext.

public extension UIImage {
    
    static func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        return ResourceManager.shared.getWeatherIcon(
            weatherCode: weatherCode,
            daylight: daylight
        )
    }
    
    static func getSunIcon() -> UIImage? {
        return ResourceManager.shared.getSunIcon()
    }
    
    static func getMoonIcon() -> UIImage? {
        return ResourceManager.shared.getMoonIcon()
    }
}

// MARK: - mtrl res manager.

class ResourceManager {
    
    // singleton.
    
    static var shared = ResourceManager()
    
    private init() {
        // do nothing.
    }
    
    // interfaces.
    
    public func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        return UIImage(
            named: self.getWeatherIconName(
                weatherCode: weatherCode,
                daylight: daylight
            )
        )
    }
    
    public func getSunIcon() -> UIImage? {
        return UIImage(
            named: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: true
            )
        )
    }
    
    public func getMoonIcon() -> UIImage? {
        return UIImage(
            named: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: false
            )
        )
    }
    
    private func getWeatherIconName(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> String {
        var name = "weather_"
        
        switch weatherCode {
        case .clear:
            name += "clear" + self.getDayNightPrifix(daylight)
        case .partlyCloudy:
            name += "partlyCloudy" + self.getDayNightPrifix(daylight)
        case .cloudy:
            name += "cloudy"
        case .rain(_):
            name += "rain"
        case .snow(_):
            name += "snow"
        case .sleet(_):
            name += "sleet"
        case .wind:
            name += "wind"
        case .fog:
            name += "fog"
        case .haze:
            name += "haze"
        case .hail:
            name += "hail"
        case .thunder:
            name += "thunder"
        case .thunderstorm:
            name += "thunderstorm"
        }
        
        return name
    }
    
    private func getDayNightPrifix(
        _ daylight: Bool
    ) -> String {
        return daylight ? "_day" : "_night"
    }
}

// MARK: - sf symbol res manager.

class SFResourceManager {
    
    // singleton.
    
    static var shared = SFResourceManager()
    
    private init() {
        // do nothing.
    }
    
    // interfaces.
    
    public func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        return self.getIcon(weatherCode: weatherCode, daylight: daylight)
    }
    
    public func getSunIcon() -> UIImage? {
        return self.getIcon(weatherCode: .clear, daylight: true)
    }
    
    public func getMoonIcon() -> UIImage? {
        return UIImage(
            systemName: "moon.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                paletteColors: [sfMoonColor, .clear, .clear]
            )
        )
    }
    
    private func getIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        let colors = self.getIconColors(
            weatherCode: weatherCode,
            daylight: daylight
        )
        return UIImage(
            systemName: self.getWeatherIconName(
                weatherCode: weatherCode,
                daylight: daylight
            ),
            withConfiguration: colors == nil
            ? UIImage.SymbolConfiguration.configurationPreferringMulticolor()
            : UIImage.SymbolConfiguration(paletteColors: colors!)
        )
    }
    
    private func getWeatherIconName(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> String {        
        switch weatherCode {
        case .clear:
            return daylight ? "sun.max.fill" : "moon.stars.fill"
        case .partlyCloudy:
            return daylight ? "cloud.sun.fill" : "cloud.moon.fill"
        case .cloudy:
            return "cloud.fill"
        case .rain(.light):
            return "cloud.drizzle.fill"
        case .rain(.middle):
            return "cloud.rain.fill"
        case .rain(.heavy):
            return "cloud.heavyrain.fill"
        case .snow(_):
            return "cloud.snow.fill"
        case .sleet(_):
            return "cloud.sleet.fill"
        case .wind:
            return "wind"
        case .fog:
            return "cloud.fog.fill"
        case .haze:
            return "aqi.medium"
        case .hail:
            return "cloud.hail.fill"
        case .thunder:
            return "cloud.bolt.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        }
    }
    
    private func getIconColors(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> [UIColor]? {
        switch weatherCode {
        case .clear:
            return daylight
            ? [sfSunColor, .clear, .clear]
            : [sfMoonColor, sfSunColor, .clear]
        case .partlyCloudy:
            return daylight
            ? [sfCloudColor, sfSunColor, .clear]
            : [sfCloudColor, sfMoonColor, .clear]
        case .cloudy:
            return [sfCloudColor, .clear, .clear]
        case .rain(.light):
            return [sfCloudColor, .systemBlue, .clear]
        case .rain(.middle):
            return [sfCloudColor, .systemBlue, .clear]
        case .rain(.heavy):
            return [sfCloudColor, .systemBlue, .clear]
        case .snow(_):
            return [sfCloudColor, sfSnowColor, .clear]
        case .sleet(_):
            return [sfCloudColor, .systemBlue, .clear]
        case .wind:
            return [.systemGreen, .clear, .clear]
        case .fog:
            return [sfCloudColor, sfSnowColor, .clear]
        case .haze:
            return [sfCloudColor, .clear, .clear]
        case .hail:
            return [sfCloudColor, sfSnowColor, .clear]
        case .thunder:
            return [sfCloudColor, sfSunColor, .clear]
        case .thunderstorm:
            return [sfCloudColor, .systemBlue, .clear]
        }
    }
}
