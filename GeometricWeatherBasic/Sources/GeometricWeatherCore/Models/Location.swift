//
//  Location.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

public func isDaylight() -> Bool {
    let hour = Calendar.current.component(.hour, from: Date())
    return 6 <= hour && hour < 18;
}

public func isDaylight(location: Location) -> Bool {
    return location.isDaylight
}

public struct Location: Equatable {
    
    public let cityId: String

    public let latitude: Double
    public let longitude: Double
    public let timezone: TimeZone
    
    public let country: String
    public let province: String
    public let city: String
    public let district: String

    public let weather: Weather?
    public let weatherSource: WeatherSource

    public let currentPosition: Bool
    public let residentPosition: Bool

    private static let nullId = "NULL_ID"
    public static let currentLocationId = "CURRENT_POSITION"
    
    enum CodingKeys: String, CodingKey {
        case cityId
        case latitude
        case longitude
        case timezone
        case country
        case province
        case city
        case district
        case weather
        case weatherSource
        case currentPosition
        case residentPosition
    }
    
    public var usable: Bool {
        get {
            return cityId != Self.nullId
        }
    }
    
    public var formattedId: String {
        get {
            return self.currentPosition
            ? Self.currentLocationId
            : (self.cityId + "&" + self.weatherSource.key)
        }
    }
    
    public var isDaylight: Bool {
        get {
            if let weather = self.weather {
                return weather.isDaylight(timezone: timezone)
            } else {
                let timezoneDate = Date(
                    timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
                        timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                    )
                )
                let hour = Calendar.current.component(.hour, from: timezoneDate)
                return 6 <= hour && hour < 18;
            }
        }
    }
    
    // MARK: - generator.
    
    public init(
        cityId: String,
        latitude: Double, longitude: Double, timezone: TimeZone,
        country: String, province: String, city: String, district: String,
        weather: Weather?, weatherSource: WeatherSource,
        currentPosition: Bool, residentPosition: Bool
    ) {
        self.cityId = cityId
        
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        
        self.country = country
        self.province = province
        self.city = city
        self.district = district
        
        self.weather = weather
        self.weatherSource = weatherSource
        
        self.currentPosition = currentPosition
        self.residentPosition = residentPosition
    }
    
    public static func buildLocal(
        weatherSource: WeatherSource
    ) -> Location {
        return Location(
            cityId: Self.nullId,
            latitude: 0,
            longitude: 0,
            timezone: TimeZone.current,
            country: "",
            province: "",
            city: "",
            district: "",
            weather: nil,
            weatherSource: weatherSource,
            currentPosition: true,
            residentPosition: false
        )
    }
    
    public static func buildDefaultLocation(
        weatherSource: WeatherSource,
        residentPosition: Bool
    ) -> Location {
        var timezone = TimeZone(identifier: "Asia/Shanghai")
        if timezone == nil {
            timezone = TimeZone.current
        }
 
        return Location(
            cityId: "101924",
            latitude: 39.904,
            longitude: 116.391,
            timezone: timezone!,
            country: "中国",
            province: "直辖市",
            city: "北京",
            district: "",
            weather: nil,
            weatherSource: weatherSource,
            currentPosition: true,
            residentPosition: residentPosition
        )
    }
    
    public func copyOf(
        cityId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timezone: TimeZone? = nil,
        country: String? = nil,
        province: String? = nil,
        city: String? = nil,
        district: String? = nil,
        weather: Weather? = nil,
        weatherSource: WeatherSource? = nil,
        currentPosition: Bool? = nil,
        residentPosition: Bool? = nil
    ) -> Location {
        return Location(
            cityId: cityId ?? self.cityId,
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude,
            timezone: timezone ?? self.timezone,
            country: country ?? self.country,
            province: province ?? self.province,
            city: city ?? self.city,
            district: district ?? self.district,
            weather: weather ?? self.weather,
            weatherSource: weatherSource ?? self.weatherSource,
            currentPosition: currentPosition ?? self.currentPosition,
            residentPosition: residentPosition ?? self.residentPosition
        )
    }
    
    // MARK: - methods.
    
    public static func == (left: Location, right: Location) -> Bool {
        
        if left.formattedId != right.formattedId {
            return false
        }
        
        if left.residentPosition != right.residentPosition {
            return false
        }
        
        if left.weatherSource != right.weatherSource {
            return false
        }
        
        if left.weather != nil && right.weather != nil {
            return left.weather! == right.weather!
        }
        
        return left.weather == nil && right.weather == nil
    }
    
    public func toString() -> String {
        var str = "\(country) \(province)"
        
        if city != "" && province != city {
            str += " \(city)"
        }
        if district != "" && city != district {
            str += " \(district)"
        }
        
        return str
    }
    
    public static func excludeInvalidResidentLocation(
        locationArray: Array<Location>
    ) -> Array<Location> {
        
        var currentLocation: Location? = nil
        for location in locationArray {
            if location.currentPosition {
                currentLocation = location
                break
            }
        }
            
        var result = [Location]();
        
        if currentLocation == nil {
            result += locationArray;
            return result
        }
        
        for location in locationArray {
            if !location.residentPosition
                || !location.isCloseTo(location: currentLocation!) {
                result.append(location)
            }
        }
        return result
    }

    private func isCloseTo(location: Location) -> Bool {
        if cityId == location.cityId {
            return true
        }
        
        if province == location.province && city == location.city {
            return true
        }
        
        return fabs(latitude - location.latitude) < 0.8
            && fabs(longitude - location.longitude) < 0.8
    }
}

extension Location: Decodable {
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            cityId: try values.decode(String.self, forKey: .cityId),
            latitude: try values.decode(Double.self, forKey: .latitude),
            longitude: try values.decode(Double.self, forKey: .longitude),
            timezone: TimeZone(identifier: try values.decode(String.self, forKey: .timezone))!,
            country: try values.decode(String.self, forKey: .country),
            province: try values.decode(String.self, forKey: .province),
            city: try values.decode(String.self, forKey: .city),
            district: try values.decode(String.self, forKey: .district),
            weather: try values.decodeIfPresent(Weather.self, forKey: .weather),
            weatherSource: WeatherSource[try values.decode(String.self, forKey: .weatherSource)],
            currentPosition: try values.decode(Bool.self, forKey: .currentPosition),
            residentPosition: try values.decode(Bool.self, forKey: .residentPosition)
        )
    }
}

extension Location: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.cityId, forKey: .cityId)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
        try container.encode(self.timezone.identifier, forKey: .timezone)
        try container.encode(self.province, forKey: .province)
        try container.encode(self.city, forKey: .city)
        try container.encode(self.district, forKey: .district)
        try container.encodeIfPresent(self.weather, forKey: .weather)
        try container.encode(self.weatherSource.key, forKey: .weatherSource)
        try container.encode(self.currentPosition, forKey: .currentPosition)
        try container.encode(self.residentPosition, forKey: .residentPosition)
        try container.encode(self.cityId, forKey: .cityId)
    }
}
