//
//  UpdateHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import GeometricWeatherBasic

private let backgroundPollingValidInterval = 0.25 // 15 minutes.

struct UpdateResult {
    let location: Location
    let locationSucceed: Bool?
    let weatherRequestSucceed: Bool
}

private struct _UpdateResult {
    let location: Location
    let isSucceed: Bool
}

class UpdateHelper {
    
    private let locator = LocationHelper()
    private var api: WeatherApi?
    
    func update(target: Location, inBackground: Bool) async -> UpdateResult {
        printLog(keyword: "update", content: "update for: \(target.formattedId)")
        self.cancelRequest()
        
        if inBackground && target.weather?.isValid(
            pollingIntervalHours: backgroundPollingValidInterval
        ) == true {
            return UpdateResult(
                location: target,
                locationSucceed: target.currentPosition ? true : nil,
                weatherRequestSucceed: true
            )
        }
        
        self.api = self.getWeatherApi(
            target.currentPosition ? SettingsManager.shared.weatherSource : target.weatherSource
        )
        
        return await withTaskCancellationHandler {
            printLog(keyword: "update", content: "begin update for: \(target.formattedId)")
            
            var result = UpdateResult(location: target, locationSucceed: nil, weatherRequestSucceed: false)
            if result.location.currentPosition {
                // location.
                
                if let locationResult = await self.locator.requestLocation(inBackground: inBackground) {
                    result = UpdateResult(
                        location: result.location.copyOf(
                            latitude: locationResult.latitude,
                            longitude: locationResult.longitude
                        ),
                        locationSucceed: true,
                        weatherRequestSucceed: false
                    )
                    await DatabaseHelper.shared.asyncWriteLocation(location: result.location)
                } else {
                    result = UpdateResult(
                        location: result.location,
                        locationSucceed: false,
                        weatherRequestSucceed: false
                    )
                }
                
                // get geo position.
                let geoResult = await self.getGeoPosition(api: self.api!, target: result.location)
                result = UpdateResult(
                    location: geoResult.location.copyOf(
                        weatherSource: SettingsManager.shared.weatherSource
                    ),
                    locationSucceed: result.locationSucceed == true && geoResult.isSucceed,
                    weatherRequestSucceed: false
                )
            }
            
            // get weather.
            let weatherResult = await self.getWeather(api: self.api!, target: result.location)
            return UpdateResult(
                location: weatherResult.location,
                locationSucceed: result.locationSucceed,
                weatherRequestSucceed: weatherResult.isSucceed
            )
        } onCancel: { [weak self] in
            printLog(keyword: "update", content: "cancel update for: \(target.formattedId)")
            self?.cancelRequest()
        }
    }
    
    private func cancelRequest() {
        self.locator.stopRequest()
        self.api?.cancel()
    }
    
    private func getWeatherApi(_ weatherSource: WeatherSource) -> WeatherApi {
        if weatherSource == .caiYun {
            return CaiYunApi()
        }
        return AccuApi()
    }
    
    // location, whether succeed.
    private func getGeoPosition(
        api: WeatherApi,
        target: Location
    ) async -> _UpdateResult {
        await withCheckedContinuation { continuation in
            printLog(keyword: "update", content: "get geo position for: \(target.formattedId)")
            
            api.getGeoPosition(target: target) { location in
                Task.detached(priority: .background) {
                    if let result = location {
                        await DatabaseHelper.shared.asyncWriteLocation(location: result)
                        continuation.resume(
                            returning: _UpdateResult(location: result, isSucceed: true)
                        )
                        return
                    }
                    
                    continuation.resume(
                        returning: _UpdateResult(
                            location: target.copyOf(
                                weather: await DatabaseHelper.shared.asyncReadWeather(
                                    formattedId: target.formattedId
                                )
                            ),
                            isSucceed: false
                        )
                    )
                }
            }
        }
    }
    
    private func getWeather(
        api: WeatherApi,
        target: Location,
        locationResult: Bool? = nil,
        geoPositionResult: Bool? = nil
    ) async -> _UpdateResult {
        await withCheckedContinuation { continuation in
            printLog(keyword: "update", content: "request weather for: \(target.formattedId)")
            
            api.getWeather(target: target){ weather in
                Task.detached(priority: .background) {
                    if let result = weather {
                        await DatabaseHelper.shared.asyncWriteWeather(
                            weather: result,
                            formattedId: target.formattedId
                        )
                        continuation.resume(
                            returning: _UpdateResult(
                                location: target.copyOf(weather: result),
                                isSucceed: true
                            )
                        )
                        return
                    }
                    
                    continuation.resume(
                        returning: _UpdateResult(
                            location: target.copyOf(
                                weather: await DatabaseHelper.shared.asyncReadWeather(
                                    formattedId: target.formattedId
                                ),
                                weatherSource: SettingsManager.shared.weatherSource
                            ),
                            isSucceed: false
                        )
                    )
                }
            }
        }
    }
}
