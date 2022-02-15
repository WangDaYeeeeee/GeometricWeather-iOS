//
//  AccuApi.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/23.
//

import Foundation
import Moya
import RxMoya
import RxSwift
import GeometricWeatherBasic

// MARK: - implementation.

private let provider = MoyaProvider<AccuService>(
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

private func getLanguage() -> String {
    if let language = Bundle.main.preferredLocalizations.first {
        return language
    }
    
    return "en-US"
}

class AccuApi: WeatherApi {
    
    func getLocation(
        _ query: String,
        callback: @escaping (Array<Location>) -> Void
    ) -> CancelToken {
        
        return CancelToken(cancelable: provider.request(
            .location(
                alias: "Always",
                apikey: ACCU_WEATHER_KEY,
                q: query,
                language: getLanguage()
            )
        ) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    callback(
                        generateLocations(
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
        })
    }
    
    func getGeoPosition(
        target: Location,
        callback: @escaping (Location?) -> Void
    ) -> CancelToken {
        
        return CancelToken(cancelable: provider.request(
            .geoPosition(
                alias: "Always",
                apikey: ACCU_WEATHER_KEY,
                q: "\(target.latitude),\(target.longitude)",
                language: getLanguage()
            )
        ) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    callback(
                        generateLocation(
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
        })
    }
    
    func getWeather(
        target: Location,
        callback: @escaping (Weather?) -> Void
    ) -> CancelToken {
        
        return CancelToken(disposable: Observable.zip(
            // current.
            provider.rx.request(
                .current(
                    city_key: target.cityId,
                    apikey: ACCU_CURRENT_KEY,
                    language: getLanguage(),
                    metric: true,
                    details: true
                )
            ).asObservable().filterSuccessfulStatusCodes().map(
                [AccuCurrentResult].self,
                failsOnEmptyData: true
            ),
            
            // daily.
            provider.rx.request(
                .daily(
                    city_key: target.cityId,
                    apikey: ACCU_WEATHER_KEY,
                    language: getLanguage(),
                    metric: true,
                    details: true
                )
            ).asObservable().filterSuccessfulStatusCodes().map(
                AccuDailyResult.self,
                failsOnEmptyData: true
            ),
            
            // hourly.
            provider.rx.request(
                .hourly(
                    city_key: target.cityId,
                    apikey: ACCU_WEATHER_KEY,
                    language: getLanguage(),
                    metric: true
                )
            ).asObservable().filterSuccessfulStatusCodes().map(
                [AccuHourlyResult].self,
                failsOnEmptyData: true
            ),
            
            // alert.
            provider.rx.request(
                .alert(
                    city_key: target.cityId,
                    apikey: ACCU_WEATHER_KEY,
                    language: getLanguage(),
                    details: true
                )
            ).asObservable().filterSuccessfulStatusCodes(),
            
            // aqi.
            provider.rx.request(
                .airQuality(
                    city_key: target.cityId,
                    apikey: ACCU_AQI_KEY
                )
            ).asObservable().filterSuccessfulStatusCodes()
        ).subscribe(onNext: { results in
            if results.0.count < 1 {
                callback(nil)
                return
            }
            
            let alerts = try? results.3.map(
                [AccuAlertResult].self,
                failsOnEmptyData: false
            )
            
            let aqi = try? results.4.map(
                AccuAirQualityResult.self,
                failsOnEmptyData: false
            )
            
            callback(
                generateWeather(
                    location: target,
                    currentResult: results.0[0],
                    dailyResult: results.1,
                    hourlyResults: results.2,
                    alertResults: alerts,
                    airQualityResult: aqi
                )
            )
        }, onError: { error in
            printLog(
                keyword: "network",
                content: "Error in weather request: \(error)"
            )
            callback(nil)
        }))
    }
}

// MARK: - abstract.

enum AccuService {
    
    case location(
        alias: String,
        apikey: String,
        q: String,
        language: String
    )

    case geoPosition(
        alias: String,
        apikey: String,
        q: String,
        language: String
    )

    case current(
        city_key: String,
        apikey: String,
        language: String,
        metric: Bool,
        details: Bool
    )

    case daily(
        city_key: String,
        apikey: String,
        language: String,
        metric: Bool,
        details: Bool
    )

    case hourly(
        city_key: String,
        apikey: String,
        language: String,
        metric: Bool
    )

    case minutely(
        apikey: String,
        language: String,
        details: Bool,
        q: String
    )

    case airQuality(
        city_key: String,
        apikey: String
    )

    case alert(
        city_key: String,
        apikey: String,
        language: String,
        details: Bool
    )
}

extension AccuService: TargetType {
    
    var baseURL: URL {
        return URL(string: ACCU_WEATHER_BASE_URL)!
    }
    
    var path: String {
        switch self {
        case .location(_, _, _, _):
            return "locations/v1/cities/translate.json"
            
        case .geoPosition(_, _, _, _):
            return "locations/v1/cities/geoposition/search.json"
            
        case .current(let city_key, _, _, _, _):
            return "currentconditions/v1/\(city_key).json"
            
        case .daily(let city_key, _, _, _, _):
            return "forecasts/v1/daily/15day/\(city_key).json"
            
        case .hourly(let city_key, _, _, _):
            return "forecasts/v1/hourly/24hour/\(city_key).json"
            
        case .minutely(_, _, _, _):
            return "forecasts/v1/minute/1minute.json"
            
        case .airQuality(let city_key, _):
            return "airquality/v1/observations/\(city_key).json"
            
        case .alert(let city_key, _, _, _):
            return "alerts/v1/\(city_key).json"
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
        case .location(let alias, let apikey, let q, let language):
            return .requestParameters(parameters: [
                "alias": alias,
                "apikey": apikey,
                "q" : q,
                "language": language,
            ], encoding: URLEncoding.queryString)
            
        case .geoPosition(let alias, let apikey, let q, let language):
            return .requestParameters(parameters: [
                "alias": alias,
                "apikey": apikey,
                "q" : q,
                "language": language,
            ], encoding: URLEncoding.queryString)
            
        case .current(_, let apikey, let language, let metric,let details):
            return .requestParameters(parameters: [
                "apikey": apikey,
                "metric" : metric ? "true": "false",
                "details" : details ? "true": "false",
                "language": language,
            ], encoding: URLEncoding.queryString)
            
        case .daily(_, let apikey, let language, let metric, let details):
            return .requestParameters(parameters: [
                "apikey": apikey,
                "metric": metric ? "true": "false",
                "details" : details ? "true": "false",
                "language": language,
            ], encoding: URLEncoding.queryString)
            
        case .hourly(_, let apikey, let language, let metric):
            return .requestParameters(parameters: [
                "metric": metric ? "true": "false",
                "apikey": apikey,
                "language": language,
            ], encoding: URLEncoding.queryString)
            
        case .minutely(let apikey, let language, let details, let q):
            return .requestParameters(parameters: [
                "details": details ? "true": "false",
                "apikey": apikey,
                "q" : q,
                "language": language,
            ], encoding: URLEncoding.queryString)
            
        case .airQuality(_, let apikey):
            return .requestParameters(parameters: [
                "apikey": apikey,
            ], encoding: URLEncoding.queryString)
            
        case .alert(_, let apikey, let language, let details):
            return .requestParameters(parameters: [
                "details": details ? "true": "false",
                "apikey": apikey,
                "language": language,
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}
