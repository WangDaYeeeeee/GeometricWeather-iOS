//
//  MaterialWeatherView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/15.
//

import SwiftUI
import GeometricWeatherResources

private let innerDelegate = MaterialWeatherThemeDelegate()

// MARK: - weather view.

public struct MaterialWeatherView: View, WeatherView {    
    
    // state.
    
    @ObservedObject private(set) public var state: WeatherViewState
    @StateObject private var gravityData = GravityReactionData()
    
    // let 2 weather view (foreground and background) appear alternately,
    // thus we can implement a switch animation with opacity.
    @State private var weatherKind1: WeatherKind
    @State private var daylight1: Bool
    @State private var weatherKind2: WeatherKind
    @State private var daylight2: Bool
    @State private var show1hide2: Bool
    @State private var show1hide2progress: Double
        
    // life cycle.
    
    public init(state: WeatherViewState) {
        self.state = state
        
        self.weatherKind1 = state.weatherKind
        self.daylight1 = state.daylight
        self.weatherKind2 = state.prevWeatherKind
        self.daylight2 = state.prevDaylight
        self.show1hide2 = true
        self.show1hide2progress = 1.0
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let width = CGFloat(                
                getTabletAdaptiveWidth(
                    maxWidth: Double(proxy.size.width)
                )
            )
            let height = proxy.size.height
            let rotation2D = gravityData.rotationControllers[0].updateRotation(
                rotation: gravityData.rotation2D,
                interval: gravityData.intervalComputers[0].update()
            )
            let rotation3D = gravityData.rotationControllers[1].updateRotation(
                rotation: gravityData.rotation3D,
                interval: gravityData.intervalComputers[1].update()
            )
            
            Group {
                // foreground 1.
                if self.show1hide2progress > 0 {
                    MtrlForegroundMapperView(
                        weatherKind: weatherKind1,
                        daylight: daylight1,
                        width: width,
                        height: height,
                        rotation2D: rotation2D,
                        rotation3D: rotation3D,
                        paddingTop: self.state.paddingTop,
                        scrollOffset: self.state.scrollOffset,
                        headerHeight: innerDelegate.getHeaderHeight(proxy.size.height)
                    ).opacity(
                        self.show1hide2progress
                    )
                }
                
                // foreground 2.
                if self.show1hide2progress < 1 {
                    MtrlForegroundMapperView(
                        weatherKind: weatherKind2,
                        daylight: daylight2,
                        width: width,
                        height: height,
                        rotation2D: rotation2D,
                        rotation3D: rotation3D,
                        paddingTop: self.state.paddingTop,
                        scrollOffset: self.state.scrollOffset,
                        headerHeight: innerDelegate.getHeaderHeight(proxy.size.height)
                    ).opacity(
                        1 - self.show1hide2progress
                    )
                }
            }.offset(
                x: CGFloat(
                    (Double(proxy.size.width) - getTabletAdaptiveWidth(
                        maxWidth: Double(proxy.size.width)
                    )) / 2.0
                ) + self.state.offsetHorizontal,
                y: 0.0
            )
        }.background(
            Group {
                // background 1.
                if self.show1hide2progress > 0 {
                    MtrlBackgroundMapperView(
                        weatherKind: weatherKind1,
                        daylight: daylight1
                    ).opacity(
                        self.show1hide2progress
                    )
                }
                // background 2.
                if self.show1hide2progress < 1 {
                    MtrlBackgroundMapperView(
                        weatherKind: weatherKind2,
                        daylight: daylight2
                    ).opacity(
                        1 - self.show1hide2progress
                    )
                }
            }
        ).onRotate {
            // switch state when interface orientation change.
            self.show1hide2.toggle()
            
            self.weatherKind1 = self.state.weatherKind
            self.daylight1 = self.state.daylight
            self.weatherKind2 = self.state.weatherKind
            self.daylight2 = self.state.daylight
            
            // change progress in animation.
            withAnimation(.easeInOut(duration: 0.4)) {
                self.show1hide2progress = self.show1hide2 ? 1 : 0
            }
        }.onChange(of: self.state.updateWeatherTime) { _ in
            // we need switch the state to right value when weather data has been update.
            self.show1hide2.toggle()
            
            if self.show1hide2 {
                // let weather view 1 show the current weather,
                // and weather view 2 show the previous weather.
                self.weatherKind1 = self.state.weatherKind
                self.daylight1 = self.state.daylight
                self.weatherKind2 = self.state.prevWeatherKind
                self.daylight2 = self.state.prevDaylight
            } else {
                // opposite ot the above satuation.
                self.weatherKind1 = self.state.prevWeatherKind
                self.daylight1 = self.state.prevDaylight
                self.weatherKind2 = self.state.weatherKind
                self.daylight2 = self.state.daylight
            }
            
            // change progress in animation.
            withAnimation(.easeInOut(duration: 0.4)) {
                self.show1hide2progress = self.show1hide2 ? 1 : 0
            }
        }.onChange(of: self.state.drawable) { newValue in
            // reset interval computers when drawable change.
            self.gravityData.resetIntervalComputers()
        }.onAppear() {
            self.gravityData.startUpdate()
        }.onDisappear() {
            self.gravityData.stopUpdate()
        } // .drawingGroup()
            .ignoresSafeArea()
    }
}

// MARK: - preview.

struct MaterialWeatherView_Previews: PreviewProvider {
    
    static var previews: some View {
        MaterialWeatherView(
            state: WeatherViewState(
                weatherKind: WeatherKind.clear,
                daylight: true
            )
        )
    }
}
