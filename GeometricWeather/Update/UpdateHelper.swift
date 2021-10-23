//
//  UpdateHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import GeometricWeatherBasic

class UpdateHelper {
    
    private let locator = LocationHelper()
    
    private let accuApi = AccuApi()
    private let caiYunApi = CaiYunApi()
    
    private var weatherRequestTokens = [CancelToken]()
    
    private func getWeatherApi(
        _ weatherSource: WeatherSource
    ) -> WeatherApi {
        if weatherSource == .caiYun {
            return self.caiYunApi
        }
        return self.accuApi
    }
    
    func update(
        target: Location,
        inBackground: Bool,
        // location, location result, weather request result.
        callback: @escaping (Location, Bool?, Bool) -> Void
    ) {
        printLog(keyword: "update", content: "update for: \(target.formattedId)")
        
        cancel()
        
        if inBackground && target.weather?.isValid(
            pollingIntervalHours: SettingsManager.shared.updateInterval.hours
        ) ?? false {
            DispatchQueue.main.async {
                callback(target, target.currentPosition ? true : nil, true)
            }
            return
        }
        
        if !target.currentPosition {
            getWeather(target: target, callback: callback)
            return
        }
        
        locator.requestLocation(inBackground: inBackground) { geoPosition in
            if let geo = geoPosition {
                let location = target.copyOf(
                    latitude: geo.0,
                    longitude: geo.1
                )
                DispatchQueue.global(qos: .background).async {
                    DatabaseHelper.shared.writeLocation(location: location)
                }
                
                self.getGeoPosition(
                    target: location,
                    locationResult: true,
                    callback: callback
                )
                return
            }
            
            if target.usable {
                self.getWeather(
                    target: target,
                    locationResult: false,
                    callback: callback
                )
                return
            }
            
            let location = Location.buildDefaultLocation(
                weatherSource: SettingsManager.shared.weatherSource,
                residentPosition: target.residentPosition
            )
            DispatchQueue.global(qos: .background).async {
                DatabaseHelper.shared.writeLocation(location: location)
            }
            
            self.getWeather(
                target: location,
                locationResult: false,
                callback: callback
            )
        }
    }
    
    private func getGeoPosition(
        target: Location,
        locationResult: Bool,
        // location, location result, weather request result.
        callback: @escaping (Location, Bool?, Bool) -> Void
    ) {
        printLog(keyword: "update", content: "get geo position for: \(target.formattedId)")
        
        let token = self.getWeatherApi(
            SettingsManager.shared.weatherSource
        ).getGeoPosition(
            target: target
        ) { location in
            if let result = location {
                DispatchQueue.global(qos: .background).async {
                    DatabaseHelper.shared.writeLocation(location: result)
                }
                
                self.getWeather(
                    target: result,
                    locationResult: locationResult,
                    geoPositionResult: true,
                    callback: callback
                )
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                let weather = DatabaseHelper.shared.readWeather(
                    formattedId: target.formattedId
                )
                DispatchQueue.main.async {
                    callback(
                        target.copyOf(weather: weather),
                        locationResult,
                        false
                    )
                }
            }
            
        }
        
        weatherRequestTokens.append(token)
    }
    
    private func getWeather(
        target: Location,
        locationResult: Bool? = nil,
        geoPositionResult: Bool? = nil,
        // location, location result, weather request result.
        callback: @escaping (Location, Bool?, Bool) -> Void
    ) {
        printLog(keyword: "update", content: "request weather for: \(target.formattedId)")
        
        let token = self.getWeatherApi(
            target.weatherSource
        ).getWeather(
            target: target
        ) { weather in
            self.weatherRequestTokens.removeAll()
            
            if let result = weather {
                DispatchQueue.global(qos: .background).async {
                    DatabaseHelper.shared.writeWeather(
                        weather: result,
                        formattedId: target.formattedId
                    )
                }
                
                callback(
                    target.copyOf(
                        weather: result
                    ),
                    locationResult,
                    geoPositionResult ?? true
                )
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                let weather = DatabaseHelper.shared.readWeather(
                    formattedId: target.formattedId
                )
                DispatchQueue.main.async {
                    callback(
                        target.copyOf(weather: weather),
                        locationResult,
                        false
                    )
                }
            }
        }
        
        weatherRequestTokens.append(token)
    }
    
    func cancel() {
        locator.stopRequest()
        
        for token in weatherRequestTokens {
            token.cancelRequest()
        }
        weatherRequestTokens.removeAll()
    }
}
