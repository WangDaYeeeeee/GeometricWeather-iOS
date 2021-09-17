//
//  WeatherView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import SwiftUI

enum WeatherKind: CaseIterable {
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

func weatherCodeToWeatherKind(code: WeatherCode) -> WeatherKind {
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

class WeatherViewState: ObservableObject {
    
    @Published private var _weatherKind: WeatherKind
    var weatherKind: WeatherKind {
        get {
            return _weatherKind
        }
    }
    
    @Published private var _prevWeatherKind = WeatherKind.null
    var prevWeatherKind: WeatherKind {
        get {
            return _prevWeatherKind
        }
    }
    
    @Published private var _daylight: Bool
    var daylight: Bool {
        get {
            return _daylight
        }
    }
    
    @Published private var _prevDaylight = true
    var prevDaylight: Bool {
        get {
            return _prevDaylight
        }
    }
    
    @Published var scrollOffset: CGFloat
    @Published var drawable: Bool
    @Published var paddingTop: CGFloat
    @Published var offsetHorizontal: CGFloat
    
    @Published var updateWeatherTime = 0.0
    
    init(
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
    
    func update(weatherKind: WeatherKind, daylight: Bool) {
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

// an abstract for different weather view impl.
protocol WeatherView {
    
    var state: WeatherViewState { get }
}

// inject colors and ui properties depend on weather.
protocol WeatherThemeDelegate {
    
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

class WeatherViewController: UIHostingController<MaterialWeatherView> {
    
    private let state = WeatherViewState(
        weatherKind: .null,
        daylight: isDaylight()
    )
    
    var scrollOffset: CGFloat {
        get {
            return state.scrollOffset
        }
        set {
            state.scrollOffset = newValue
        }
    }
    
    var drawable: Bool {
        get {
            return state.drawable
        }
        set {
            state.drawable = newValue
        }
    }
    
    var paddingTop: CGFloat {
        get {
            return state.paddingTop
        }
        set {
            state.paddingTop = newValue
        }
    }
    
    var offsetHorizontal: CGFloat {
        get {
            return state.offsetHorizontal
        }
        set {
            state.offsetHorizontal = newValue
        }
    }
    
    init() {
        super.init(rootView: MaterialWeatherView(state: state))
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(weatherKind: WeatherKind, daylight: Bool) {
        state.update(weatherKind: weatherKind, daylight: daylight)
    }
}
