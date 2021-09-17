//
//  Location.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

struct Location: Equatable {
    
    let cityId: String

    let latitude: Double
    let longitude: Double
    let timezone: TimeZone
    
    let country: String
    let province: String
    let city: String
    let district: String

    let weather: Weather?
    let weatherSource: WeatherSource

    let currentPosition: Bool
    let residentPosition: Bool

    private static let nullId = "NULL_ID"
    static let currentLocationId = "CURRENT_POSITION"
    
    var usable: Bool {
        get {
            return cityId != Self.nullId
        }
    }
    
    var formattedId: String {
        get {
            return currentPosition
                ? Self.currentLocationId
                : (cityId + "&" + weatherSource.key)
        }
    }
    
    var daylight: Bool {
        get {
            if let w = weather {
                return w.isDaylight(timezone: timezone)
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
    
    init(
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
    
    static func buildLocal() -> Location {
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
            weatherSource: WeatherSource[0],
            currentPosition: true,
            residentPosition: false
        )
    }
    
    static func buildDefaultLocation(
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
    
    func copyOf(
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
    
    static func == (left: Location, right: Location) -> Bool {
        
        if left.formattedId != right.formattedId {
            return false
        }
        
        if left.residentPosition != right.residentPosition {
            return false
        }
        
        if left.weather != nil && right.weather != nil {
            return left.weather! == right.weather!
        }
        
        return left.weather == nil && right.weather == nil
    }
    
    func toString() -> String {
        var str = "\(country) \(province)"
        
        if city != "" && province != city {
            str += " \(city)"
        }
        if district != "" && city != district {
            str += " \(district)"
        }
        
        return str
    }
    
    static func excludeInvalidResidentLocation(
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
