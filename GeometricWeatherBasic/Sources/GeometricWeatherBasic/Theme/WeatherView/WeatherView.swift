//
//  WeatherView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import SwiftUI

// MARK: - weather kind.

public enum WeatherKind: CaseIterable {
    case null
    case clear
    case cloud
    case cloudy
    case lightRainy
    case middleRainy
    case haveyRainy
    case snow
    case sleet
    case hail
    case fog
    case haze
    case thunder
    case thunderstorm
    case wind
}

public func weatherCodeToWeatherKind(code: WeatherCode) -> WeatherKind {
    switch code {
    case .clear:
        return .clear

    case .partlyCloudy:
        return .cloud

    case .cloudy:
        return .cloudy

    case .rain(.light):
        return .lightRainy
        
    case .rain(.middle):
        return .middleRainy
        
    case .rain(.heavy):
        return .haveyRainy

    case .snow:
        return .snow

    case .wind:
        return .wind

    case .fog:
        return .fog

    case .haze:
        return .haze

    case .sleet:
        return .sleet

    case .hail:
        return .hail

    case .thunder:
        return .thunder

    case .thunderstorm:
        return .thunderstorm
    }
}

// MARK: - state.

public class WeatherViewState: ObservableObject {
    
    @Published private var _weatherKind: WeatherKind
    public var weatherKind: WeatherKind {
        get {
            return _weatherKind
        }
    }
    
    @Published private var _prevWeatherKind = WeatherKind.null
    public var prevWeatherKind: WeatherKind {
        get {
            return _prevWeatherKind
        }
    }
    
    @Published private var _daylight: Bool
    public var daylight: Bool {
        get {
            return _daylight
        }
    }
    
    @Published private var _prevDaylight = true
    public var prevDaylight: Bool {
        get {
            return _prevDaylight
        }
    }
    
    @Published public var scrollOffset: CGFloat
    @Published public var drawable: Bool
    @Published public var paddingTop: CGFloat
    @Published public var offsetHorizontal: CGFloat
    
    @Published public var updateWeatherTime = 0.0
    
    public init(
        weatherKind: WeatherKind,
        daylight: Bool,
        scrollOffset: CGFloat = 0.0,
        drawable: Bool = true,
        paddingTop: CGFloat = 0.0,
        offsetHorizontal: CGFloat = 0.0
    ) {
        self._weatherKind = weatherKind
        self._daylight = daylight
        self.scrollOffset = scrollOffset
        self.drawable = drawable
        self.paddingTop = paddingTop
        self.offsetHorizontal = offsetHorizontal
    }
    
    public func update(weatherKind: WeatherKind, daylight: Bool) {
        if weatherKind == _weatherKind && daylight == _daylight {
            return
        }
        
        self._prevWeatherKind = self._weatherKind
        self._prevDaylight = self._daylight
        
        self._weatherKind = weatherKind
        self._daylight = daylight
        
        self.updateWeatherTime = Date().timeIntervalSince1970
    }
}

// MARK: - weather view.

// an abstract for different weather view impl.
public protocol WeatherView {
    
    var state: WeatherViewState { get }
}

// MARK: - theme delegate.

// inject colors and ui properties depend on weather.
public protocol WeatherThemeDelegate {
        
    // @return (
    //     main theme color,
    //     color of daytime chart line,
    //     color of nighttime chart line
    // )
    func getThemeColors(
        weatherKind: WeatherKind,
        daylight: Bool,
        lightTheme: Bool
    ) -> (main: UIColor, daytime: UIColor, nighttime: UIColor)
    
    func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat
}
