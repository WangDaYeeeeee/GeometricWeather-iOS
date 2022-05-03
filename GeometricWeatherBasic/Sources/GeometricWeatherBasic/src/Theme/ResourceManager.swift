//
//  ResourceManager.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/14.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - ui image ext.

@available(iOS 8.0, *)
public extension UIImage {
    
    convenience init?(namedInBasic name: String) {
        self.init(named: name, in: .module, with: nil)
    }
    
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

// MARK: - ui image ext.

public extension Image {
    
    init?(namedInBasic name: String) {
        self.init(name, bundle: .module)
    }
    
    static func getWeatherIcon(
        weatherCode: WeatherCode,
        daylight: Bool
    ) -> Image? {
        return ResourceManager.shared.getWeatherIcon(
            weatherCode: weatherCode,
            daylight: daylight
        )
    }
    
    static func getSunIcon() -> Image? {
        return ResourceManager.shared.getSunIcon()
    }
    
    static func getMoonIcon() -> Image? {
        return ResourceManager.shared.getMoonIcon()
    }
}

// MARK: - mtrl res manager.

class ResourceManager {
    
    // singleton.
    
    static let shared = ResourceManager()
    
    private init() {
        // do nothing.
    }
    
    // MARK: - ui image.
    
    @available(iOS 8.0, *)
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
    
    @available(iOS 8.0, *)
    public func getSunIcon() -> UIImage? {
        return UIImage(
            namedInBasic: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: true
            )
        )
    }
    
    @available(iOS 8.0, *)
    public func getMoonIcon() -> UIImage? {
        return UIImage(
            namedInBasic: self.getWeatherIconName(
                weatherCode: .clear,
                daylight: false
            )
        )
    }
    
    // MARK: - swiftUI image.
    
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
    
    // MARK: - image name.
    
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
