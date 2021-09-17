//
//  LocationHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/22.
//

import Foundation
import CoreLocation

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
        
        if isRunning {
            callbacks.append(callback)
            return
        }
        
        isRunning = true
        callbacks.append(callback)
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 0
        self.locationManager.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        timer = Timer.scheduledTimer(withTimeInterval: timeOut, repeats: false) { timer in
            if let location = self.locationManager.location {
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
            
            self.stopRequest()
        }
    }
    
    func stopRequest() {
        self.locationManager.stopUpdatingLocation()
        callbacks.removeAll()
        isRunning = false
        
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - protocols.
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            for callback in callbacks {
                callback((
                    location.coordinate.latitude,
                    location.coordinate.longitude
                ))
            }
            stopRequest()
        }
    }
}
