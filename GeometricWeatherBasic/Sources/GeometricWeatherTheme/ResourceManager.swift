//
//  ResourceManager.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/14.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources

// MARK: - ui image ext.

public extension UIImage {
    
    convenience init?(namedInBasic name: String) {
        self.init(named: name, in: .shared, with: nil)
    }
    
    static func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        return MaterialResourceProvider.shared.getWeatherIcon(
            weatherCode: weatherCode,
            daylight: daylight
        )
    }
    
    static func getSunIcon() -> UIImage? {
        return MaterialResourceProvider.shared.getSunIcon()
    }
    
    static func getMoonIcon() -> UIImage? {
        return MaterialResourceProvider.shared.getMoonIcon()
    }
}

// MARK: - ui image ext.

public extension Image {
    
    init?(namedInBasic name: String) {
        self.init(name, bundle: .shared)
    }
    
    static func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> Image? {
        return MaterialResourceProvider.shared.getWeatherIcon(
            weatherCode: weatherCode,
            daylight: daylight
        )
    }
    
    static func getSunIcon() -> Image? {
        return MaterialResourceProvider.shared.getSunIcon()
    }
    
    static func getMoonIcon() -> Image? {
        return MaterialResourceProvider.shared.getMoonIcon()
    }
}

// MARK: - res provider.

public protocol ResourceProvider {
    
    // ui image.
    
    func getWeatherIcon(weatherCode: WeatherCode, daylight: Bool) -> UIImage?
    func getSunIcon() -> UIImage?
    func getMoonIcon() -> UIImage?
    
    // swiftUI image.
    
    func getWeatherIcon(weatherCode: WeatherCode, daylight: Bool) -> Image?
    func getSunIcon() -> Image?
    func getMoonIcon() -> Image?
}

// MARK: - mtrl res provider.

public class MaterialResourceProvider: ResourceProvider {
    
    public static let shared = MaterialResourceProvider()
    
    private init() {
        
    }
    
    // ui image.
    
    public func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        return UIImage(
            namedInBasic: self.getWeatherIconName(
                weatherCode: weatherCode,
                daylight: daylight
            )
        )
    }
    
    public func getSunIcon() -> UIImage? {
        return UIImage(
            namedInBasic: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: true
            )
        )
    }
    
    public func getMoonIcon() -> UIImage? {
        return UIImage(
            namedInBasic: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: false
            )
        )
    }
    
    // swiftUI image.
    
    public func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> Image? {
        return Image(
            namedInBasic: self.getWeatherIconName(
                weatherCode: weatherCode,
                daylight: daylight
            )
        )
    }
    
    public func getSunIcon() -> Image? {
        return Image(
            namedInBasic: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: true
            )
        )
    }
    
    public func getMoonIcon() -> Image? {
        return Image(
            namedInBasic: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: false
            )
        )
    }
    
    // image name.
    
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

// MARK: - sf res provider.

public class SFResourceProvider: ResourceProvider {
    
    public static let shared = SFResourceProvider()
    
    private init() {
        
    }
    
    // ui image.
    
    public func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> UIImage? {
        return UIImage(
            systemName: self.getWeatherIconName(
                weatherCode: weatherCode,
                daylight: daylight
            )
        )
    }
    
    public func getSunIcon() -> UIImage? {
        return UIImage(
            systemName: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: true
            )
        )
    }
    
    public func getMoonIcon() -> UIImage? {
        return UIImage(
            systemName: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: false
            )
        )
    }
    
    // swiftUI image.
    
    public func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> Image? {
        return Image(
            systemName: self.getWeatherIconName(
                weatherCode: weatherCode,
                daylight: daylight
            )
        )
    }
    
    public func getSunIcon() -> Image? {
        return Image(
            systemName: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: true
            )
        )
    }
    
    public func getMoonIcon() -> Image? {
        return Image(
            systemName: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: false
            )
        )
    }
    
    // image name.
    
    public func getWeatherIconName(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> String {
        switch weatherCode {
        case .clear:
            return daylight ? "sun.max" : "moon.stars"
        case .partlyCloudy:
            return daylight ? "cloud.sun" : "cloud.moon"
        case .cloudy:
            return "cloud"
        case .rain(_):
            return "cloud.rain"
        case .snow(_):
            return "cloud.snow"
        case .sleet(_):
            return "cloud.sleet"
        case .wind:
            return "wind"
        case .fog:
            return "cloud.fog"
        case .haze:
            return "aqi.medium"
        case .hail:
            return "cloud.hail"
        case .thunder:
            return "cloud.bolt"
        case .thunderstorm:
            return "cloud.bolt.rain"
        }
    }
}
