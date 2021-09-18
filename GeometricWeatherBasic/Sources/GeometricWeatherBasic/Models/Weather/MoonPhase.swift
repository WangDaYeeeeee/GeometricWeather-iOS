//
//  MoonPhase.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct MoonPhase: Codable {
    
    public let angle: Int?
    public let description: String?
    
    public init(angle: Int?, description: String?) {
        self.angle = angle
        self.description = description
    }
    
    public func isValid() -> Bool {
        return angle != nil && description != nil
    }
    
    public func getMoonPhaseKey() -> String {
        if let des = description {
            switch des.lowercased() {
            case "waxingcrescent":
                return "phase_waxing_crescent"
            case "waxing crescent":
                return "phase_waxing_crescent"

            case "first":
                return "phase_first"
            case "firstquarter":
                return "phase_first"
            case "first quarter":
                return "phase_first"

            case "waxinggibbous":
                return "phase_waxing_gibbous"
            case "waxing gibbous":
                return "phase_waxing_gibbous"

            case "full":
                return "phase_full"
            case "fullmoon":
                return "phase_full"
            case "full moon":
                return "phase_full"

            case "waninggibbous":
                return "phase_waning_gibbous"
            case "waning gibbous":
                return "phase_waning_gibbous"

            case "third":
                return "phase_third"
            case "thirdquarter":
                return "phase_third"
            case "third quarter":
                return "phase_third"
            case "last":
                return "phase_third"
            case "lastquarter":
                return "phase_third"
            case "last quarter":
                return "phase_third"

            case "waningcrescent":
                return "phase_waning_crescent"
            case "waning crescent":
                return "phase_waning_crescent"

            default:
                return "phase_new"
            }
        } else {
            return "phase_new"
        }
    }
}
