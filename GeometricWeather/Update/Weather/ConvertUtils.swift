//
//  Utils.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import GeometricWeatherBasic

func toInt(_ value: Double) -> Int {
  return Int(value + 0.5)
}

func getWindLevelInt(speed: Double) -> Int {
    if speed < 1 {
        return 0
    } else if speed < 5 {
        return 1
    } else if speed < 11 {
        return 2
    } else if speed < 19 {
        return 3
    } else if speed < 28 {
        return 4
    } else if speed < 38 {
        return 5
    } else if speed < 49 {
        return 6
    } else if speed < 61 {
        return 7
    } else if speed < 74 {
        return 8
    } else if speed < 88 {
        return 9
    } else if speed < 102 {
        return 10
    } else if speed < 117 {
        return 11
    } else {
        return 12
    }
}

func getAqiQualityInt(index: Int) -> Int {
  if (index < 0) {
    return 0;
  } else if (index <= aqiIndexLevel1) {
    return 1;
  } else if (index <= aqiIndexLevel2) {
    return 2;
  } else if (index <= aqiIndexLevel3) {
    return 3;
  } else if (index <= aqiIndexLevel4) {
    return 4;
  } else if (index <= aqiIndexLevel5) {
    return 5;
  } else {
    return 6;
  }
}

func getMoonPhaseAngle(phase: String) -> Int? {
    if (phase.isEmpty) {
    return nil;
  }
    switch (phase.lowercased()) {
    case "waxingcrescent":
        return 45;
    case "waxing crescent":
        return 45;

    case "first":
        return 90;
    case "firstquarter":
        return 90;
    case "first quarter":
        return 90;

    case "waxinggibbous":
        return 135;
    case "waxing gibbous":
        return 135;

    case "full":
        return 180;
    case "fullmoon":
        return 180;
    case "full moon":
        return 180;

    case "waninggibbous":
        return 225;
    case "waning gibbous":
        return 225;

    case "third":
        return 270;
    case "thirdquarter":
        return 270;
    case "third quarter":
        return 270;
    case "last":
        return 270;
    case "lastquarter":
        return 270;
    case "last quarter":
        return 270;

    case "waningcrescent":
        return 315;
    case "waning crescent":
        return 315;

    default:
        return 360;
  }
}

func getPrecipitationIntensityInPercentage(
    intensityInRadarStandard: [Double]
) -> [Double] {
    return intensityInRadarStandard.map { value in
        min(value / radarPrecipitationIntensityHeavy, 1.0)
    }
}

func isDaylight(sunrise: Date, sunset: Date, current: Date) -> Bool {
    return sunrise.timeIntervalSince1970 < current.timeIntervalSince1970
        && current.timeIntervalSince1970 < sunset.timeIntervalSince1970
}
