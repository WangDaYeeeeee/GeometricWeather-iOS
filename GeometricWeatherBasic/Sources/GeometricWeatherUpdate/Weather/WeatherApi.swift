//
//  WeatherApi.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/23.
//

import Foundation
import Moya
import RxSwift
import GeometricWeatherCore

public func getWeatherApi(_ weatherSource: WeatherSource) -> WeatherApi {
    if weatherSource == .caiYun {
        return CaiYunApi()
    }
    return AccuApi()
}

public protocol WeatherApi {
        
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
        units: UnitSet,
        callback: @escaping (Weather?) -> Void
    )
    
    func cancel()
}

public struct CancelToken {
    
    private let cancellable: Cancellable?
    private let disposable: Disposable?
    
    public init(
        cancellable: Cancellable? = nil,
        disposable: Disposable? = nil
    ) {
        self.cancellable = cancellable
        self.disposable = disposable
    }
    
    public func cancelRequest() {
        cancellable?.cancel()
        disposable?.dispose()
    }
}
