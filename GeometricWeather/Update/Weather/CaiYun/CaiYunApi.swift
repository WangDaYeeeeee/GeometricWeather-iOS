//
//  CaiYunApi.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/20.
//

import Foundation
import Moya
import RxSwift
import GeometricWeatherBasic

// MARK: - implementation.

private let accuProvider = MoyaProvider<AccuService>(
    plugins: getPlugins()
)
private let caiYunProvider = MoyaProvider<CaiYunService>(
    plugins: getPlugins()
)

private func getPlugins() -> [PluginType] {
#if DEBUG
    return [
        NetworkLoggerPlugin()
    ]
#else
    return []
#endif
}

private func getLanguageForCaiYunApi() -> String {
    if let language = Bundle.main.preferredLocalizations.first {
        if language == "zh-Hans" {
            return "zh_CN"
        }
        if language == "zh-Hant" {
            return "zh_TW"
        }
        if language.contains("ja") {
            return "ja"
        }
    }
    
    return "en_US"
}

private func getLanguageForAccuApi() -> String {
    if let language = Bundle.main.preferredLocalizations.first {
        return language
    }
    
    return "en-US"
}

class CaiYunApi: WeatherApi {
    
    var taskCancelToken: CancelToken?
    
    func getLocation(
        _ query: String,
        callback: @escaping (Array<Location>) -> Void
    ) {
        let cancellable = accuProvider.request(
            .location(
                alias: "Always",
                apikey: BuildConfig.current.accuWeatherKey,
                q: query,
                language: getLanguageForAccuApi()
            )
        ) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    callback(
                        caiYunGenerateLocationsByAccuSource(
                            try moyaResponse.map([AccuLocationResult].self),
                            zipCode: query.isZipCode() ? query : nil
                        )
                    )
                } catch {
                    printLog(
                        keyword: "network",
                        content: "JSON convert error: \(error)"
                    )
                    callback([])
                }
                break
                
            default:
                callback([])
                break
            }
        }
        self.taskCancelToken = CancelToken(cancellable: cancellable)
    }
    
    func getGeoPosition(
        target: Location,
        callback: @escaping (Location?) -> Void
    ) {
        let cancellable = accuProvider.request(
            .geoPosition(
                alias: "Always",
                apikey: BuildConfig.current.accuWeatherKey,
                q: "\(target.latitude),\(target.longitude)",
                language: getLanguageForAccuApi()
            )
        ) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    callback(
                        caiYunGenerateLocationByAccuSource(
                            try moyaResponse.map(AccuLocationResult.self),
                            src: target
                        )
                    )
                } catch {
                    printLog(
                        keyword: "network",
                        content: "JSON convert error: \(error)"
                    )
                    callback(nil)
                }
                break
                
            default:
                callback(nil)
                break
            }
        }
        self.taskCancelToken = CancelToken(cancellable: cancellable)
    }
    
    func getWeather(
        target: Location,
        callback: @escaping (Weather?) -> Void
    ) {
        let disposable = Observable.zip(
            // weather.
            caiYunProvider.rx.request(
                .weather(
                    latitude: target.latitude,
                    longitude: target.longitude,
                    language: getLanguageForCaiYunApi()
                )
            ).asObservable().filterSuccessfulStatusCodes().map(
                CaiYunWeatherResult.self,
                failsOnEmptyData: true
            ),
            
            // history.
            accuProvider.rx.request(
                .current(
                    city_key: target.cityId,
                    apikey: BuildConfig.current.accuCurrentKey,
                    language: getLanguageForAccuApi(),
                    metric: true,
                    details: true
                )
            ).asObservable().filterSuccessfulStatusCodes().map(
                [AccuCurrentResult].self,
                failsOnEmptyData: true
            ),
            
            // moon phase & moon rise/set.
            accuProvider.rx.request(
                .daily(
                    city_key: target.cityId,
                    apikey: BuildConfig.current.accuWeatherKey,
                    language: getLanguageForAccuApi(),
                    metric: true,
                    details: true
                )
            ).asObservable().filterSuccessfulStatusCodes().map(
                AccuDailyResult.self,
                failsOnEmptyData: true
            )
        ).subscribe(onNext: { results in
            if results.1.count < 1 {
                callback(nil)
                return
            }
            
            callback(
                generateWeather(
                    location: target,
                    weatherResult: results.0,
                    historyResult: results.1[0],
                    moonResult: results.2
                )
            )
        }, onError: { error in
            printLog(
                keyword: "network",
                content: "Error in weather request: \(error)"
            )
            callback(nil)
        })
        self.taskCancelToken = CancelToken(disposable: disposable)
    }
    
    func cancel() {
        self.taskCancelToken?.cancelRequest()
        self.taskCancelToken = nil
    }
}

// MARK: - abstract.

enum CaiYunService {

    case weather(
        latitude: Double,
        longitude: Double,
        language: String
    )
}

extension CaiYunService: TargetType {
    
    var baseURL: URL {
        return URL(
            string: "\(BuildConfig.current.caiyunWeatherBaseUrl)\(BuildConfig.current.caiyunWeatherApiKey)"
        )!
    }
    
    var path: String {
        switch self {
        case .weather(let latitude, let longitude, _):
            return "\(longitude),\(latitude)/weather.json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .weather(_, _, let language):
            return .requestParameters(parameters: [
                "lang": language,
                "dailysteps": 15,
                "hourlysteps" : 48,
                "alert": "true",
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}
