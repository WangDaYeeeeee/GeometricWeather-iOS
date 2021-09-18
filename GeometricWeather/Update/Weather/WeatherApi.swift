//
//  WeatherApi.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/23.
//

import Foundation
import Moya
import RxSwift
import GeometricWeatherBasic

func getWeatherApi(_ weatherSource: WeatherSource) -> WeatherApi {
    return AccuApi()
}

protocol WeatherApi {
    
    func getLocation(
        _ query: String,
        callback: @escaping (Array<Location>) -> Void
    ) -> CancelToken
    
    func getGeoPosition(
        target: Location,
        callback: @escaping (Location?) -> Void
    ) -> CancelToken
    
    func getWeather(
        target: Location,
        callback: @escaping (Weather?) -> Void
    ) -> CancelToken
}

class CancelToken {
    
    private let cancelable: Cancellable?
    private let disposable: Disposable?
    
    init(
        cancelable: Cancellable? = nil,
        disposable: Disposable? = nil
    ) {
        self.cancelable = cancelable
        self.disposable = disposable
    }
    
    func cancelRequest() {
        cancelable?.cancel()
        disposable?.dispose()
    }
}
