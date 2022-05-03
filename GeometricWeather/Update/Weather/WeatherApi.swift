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
    if weatherSource == .caiYun {
        return CaiYunApi()
    }
    return AccuApi()
}

protocol WeatherApi {
        
    func getLocation(
        _ query: String,
        callback: @escaping (Array<Location>) -> Void
    )
    
    func getGeoPosition(
        target: Location,
        callback: @escaping (Location?) -> Void
    )
    
    func getWeather(
        target: Location,
        callback: @escaping (Weather?) -> Void
    )
    
    func cancel()
}

struct CancelToken {
    
    private let cancellable: Cancellable?
    private let disposable: Disposable?
    
    init(
        cancellable: Cancellable? = nil,
        disposable: Disposable? = nil
    ) {
        self.cancellable = cancellable
        self.disposable = disposable
    }
    
    func cancelRequest() {
        cancellable?.cancel()
        disposable?.dispose()
    }
}
