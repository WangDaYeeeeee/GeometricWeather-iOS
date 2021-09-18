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
  if (speed <= 0) {
    return 0;
  } else if (speed <= 1) {
    return 1;
  } else if (speed <= 2) {
    return 2;
  } else if (speed <= 3) {
    return 3;
  } else if (speed <= 4) {
    return 4;
  } else if (speed <= 5) {
    return 5;
  } else if (speed <= 6) {
    return 6;
  } else if (speed <= 7) {
    return 7;
  } else if (speed <= 8) {
    return 8;
  } else if (speed <= 9) {
    return 9;
  } else if (speed <= 10) {
    return 10;
  } else if (speed <= 11) {
    return 11;
  } else {
    return 12;
  }
}

func getAqiQualityInt(index: Int) -> Int {
  if (index < 0) {
    return 0;
  } else if (index <= AirQuality.aqiIndexLevel1) {
    return 1;
  } else if (index <= AirQuality.aqiIndexLevel2) {
    return 2;
  } else if (index <= AirQuality.aqiIndexLevel3) {
    return 3;
  } else if (index <= AirQuality.aqiIndexLevel4) {
    return 4;
  } else if (index <= AirQuality.aqiIndexLevel5) {
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

func isDaylight(sunrise: Date, sunset: Date, current: Date) -> Bool {
    return sunrise.timeIntervalSince1970 < current.timeIntervalSince1970
        && current.timeIntervalSince1970 < sunset.timeIntervalSince1970
}
