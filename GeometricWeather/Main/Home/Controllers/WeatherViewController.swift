//
//  WeatherViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/18.
//

import SwiftUI
import GeometricWeatherTheme

public class WeatherViewController<V: WeatherView>: UIHostingController<V> {
    
    private let state: WeatherViewState
    
    public var scrollOffset: CGFloat {
        get {
            return state.scrollOffset
        }
        set {
            state.scrollOffset = newValue
        }
    }
    
    public var drawable: Bool {
        get {
            return state.drawable
        }
        set {
            state.drawable = newValue
        }
    }
    
    public var paddingTop: CGFloat {
        get {
            return state.paddingTop
        }
        set {
            state.paddingTop = newValue
        }
    }
    
    public var offsetHorizontal: CGFloat {
        get {
            return state.offsetHorizontal
        }
        set {
            state.offsetHorizontal = newValue
        }
    }
    
    public init(_ rootView: V, state: WeatherViewState) {
        self.state = state
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(weatherKind: WeatherKind, daylight: Bool) {
        state.update(weatherKind: weatherKind, daylight: daylight)
    }
}
