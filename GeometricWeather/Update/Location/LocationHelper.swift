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

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var isRunning = false
    private var callbacks = [((Double, Double)?) -> Void]()
    
    private var timer: Timer?
    
    func requestLocation(
        inBackground: Bool,
        // latitude, longitude.
        _ callback: @escaping ((Double, Double)?) -> Void
    ) {
        printLog(keyword: "update", content: "location begin")
        
        if inBackground {
            if let location = self.locationManager.location {
                callback((
                    location.coordinate.latitude,
                    location.coordinate.longitude
                ))
            } else {
                callback(nil)
            }
            return
        }
        
        if self.isRunning {
            self.callbacks.append(callback)
            return
        }
        
        self.isRunning = true
        self.callbacks.append(callback)
        
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
        self.callbacks.removeAll()
        self.isRunning = false
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        
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
            for callback in self.callbacks {
                callback((
                    location.coordinate.latitude,
                    location.coordinate.longitude
                ))
            }
        } else {
            for callback in self.callbacks {
                callback(nil)
            }
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
}
