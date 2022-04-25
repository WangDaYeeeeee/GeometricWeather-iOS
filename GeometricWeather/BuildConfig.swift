//
//  BuildConfig.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/4/25.
//

import Foundation

// MARK: - build config.

enum BuildConfig: String {
    
    case debug
    case release
    
    static var current: BuildConfigProtocal {
        guard let rawValue = Bundle.main.infoDictionary?["Configuration"] as? String else {
            fatalError("No Configuration Found")
        }

        guard let instance = BuildConfig(rawValue: rawValue.lowercased()) else {
            fatalError("Invalid Configuration Name")
        }

        switch instance {
        case .debug:
            return DebugConfig()
        case .release:
            return ReleaseConfig()
        }
    }
}

// MARK: - protocal.

protocol BuildConfigProtocal {
    
    var defaultWeatherSourceId: String { get }
    
    var accuWeatherKey: String { get }
    var accuCurrentKey: String { get }
    var accuAqiKey: String { get }
    var accuWeatherBaseUrl: String { get }

    var caiyunWeatherApiKey: String { get }
    var caiyunWeatherBaseUrl: String { get }
}

// MARK: - debug impl.

private struct DebugConfig: BuildConfigProtocal {
    
    var defaultWeatherSourceId: String {
        return "accu"
    }
    
    var accuWeatherKey: String {
        return "srRLeAmTroxPinDG8Aus3Ikl6tLGJd94"
    }
    
    var accuCurrentKey: String {
        return "131778526309453295c9ce2350a79e87"
    }
    
    var accuAqiKey: String {
        return "7f8c4da3ce9849ffb2134f075201c45a"
    }
    
    var accuWeatherBaseUrl: String {
        return "https://api.accuweather.com/"
    }
    
    var caiyunWeatherApiKey: String {
        return ""
    }
    
    var caiyunWeatherBaseUrl: String {
        return "https://api.caiyunapp.com/v2.5/"
    }
}

// MARK: - release impl.

// Hide release keywords on GitHub.
private struct ReleaseConfig: BuildConfigProtocal {
    
    var defaultWeatherSourceId: String {
        return "caiyun"
    }
    
    var accuWeatherKey: String {
        return ""
    }
    
    var accuCurrentKey: String {
        return ""
    }
    
    var accuAqiKey: String {
        return ""
    }
    
    var accuWeatherBaseUrl: String {
        return "https://api.accuweather.com/"
    }
    
    var caiyunWeatherApiKey: String {
        return ""
    }
    
    var caiyunWeatherBaseUrl: String {
        return "https://api.caiyunapp.com/v2.5/"
    }
}
