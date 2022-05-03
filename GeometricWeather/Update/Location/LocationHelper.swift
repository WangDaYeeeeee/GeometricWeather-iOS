//
//  LocationHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/22.
//

import Foundation
import CoreLocation
import GeometricWeatherBasic

private let timeOut = 10.0

struct LocationResult {
    let latitude: Double
    let longitude: Double
}

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    private var timer: Timer?
    private var callback: ((LocationResult?) -> Void)?
    
    func requestLocation(inBackground: Bool) async -> LocationResult? {
        await withCheckedContinuation { continuation in
            self.requestLocation(inBackground: inBackground) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func requestLocation(
        inBackground: Bool,
        _ callback: @escaping (LocationResult?) -> Void
    ) {
        printLog(keyword: "update", content: "location begin")
        
        if inBackground {
            if let location = self.locationManager.location {
                callback(
                    LocationResult(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                )
            } else {
                callback(nil)
            }
            return
        }
        
        self.callback = callback
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 0
        self.locationManager.delegate = self
        
        let authStatus = self.locationManager.authorizationStatus
        
        if authStatus == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
            return
        }
        
        if authStatus == .authorizedAlways
            || authStatus == .authorizedWhenInUse {
            self.startUpdatingLocation()
            return
        }
        
        self.publishResult(nil)
        self.stopRequest()
    }
    
    func stopRequest() {
        self.locationManager.stopUpdatingLocation()
        self.callback = nil
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func startUpdatingLocation() {
        self.locationManager.requestLocation()
        
        self.timer = Timer.scheduledTimer(
            withTimeInterval: timeOut,
            repeats: false
        ) { timer in
            self.publishResult(self.locationManager.location)
            self.stopRequest()
        }
    }
    
    private func publishResult(_ result: CLLocation?) {
        if let location = result {
            self.callback?(
                LocationResult(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            )
        } else {
            self.callback?(nil)
        }
    }
    
    // MARK: - delegate.
    
    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        if manager.authorizationStatus == .authorizedAlways
            || manager.authorizationStatus == .authorizedWhenInUse {
            self.startUpdatingLocation()
            return
        }
        
        self.publishResult(nil)
        self.stopRequest()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            self.publishResult(location)
            self.stopRequest()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.publishResult(nil)
        self.stopRequest()
    }
}
