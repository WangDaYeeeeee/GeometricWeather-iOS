//
//  AnimationControll.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/15.
//

import SwiftUI
import CoreMotion

private let gravity = -9.81

// MARK: - observerable.

class TimerInvalidateData: ObservableObject {
    
    @Published var intervalInMillis: Int64 = 0
    
    private var timer: Timer?
    private let intervalComputer = IntervalComputer()
    
    func startInvalidate() {
        if timer != nil {
            return
        }
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.008,
            repeats: true
        ) { _ in
            self.intervalInMillis = self.intervalComputer.update()
        }
    }
    
    func stopInvalidate() {
        timer?.invalidate()
        timer = nil
    }
}

class GravityReactionData: ObservableObject {
    
    @Published var rotation2D = 0.0
    @Published var rotation3D = 0.0
    
    private var accelerometers: Array<Double?> = [nil, nil, nil]
    private var userAccelerometers: Array<Double?> = [nil, nil, nil]
    private var accelerometersOfGravity: Array<Double?> = [nil, nil, nil]

    private let motionManager = CMMotionManager()
    
    let intervalComputers = [
        IntervalComputer(),
        IntervalComputer(),
    ]
    let rotationControllers = [
        DelayRotationController(initRotation: 0.0),
        DelayRotationController(initRotation: 0.0),
    ]
    
    // update.
    
    func startUpdate() {
        motionManager.accelerometerUpdateInterval = 0.0
        motionManager.deviceMotionUpdateInterval = 0.0
        
        motionManager.startAccelerometerUpdates(
            to: .main,
            withHandler: handleAccelerometer
        )
        motionManager.startDeviceMotionUpdates(
            to: .main,
            withHandler: handleDeviceMotion
        )
    }
    
    func stopUpdate() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func resetIntervalComputers() {
        for item in intervalComputers {
            item.reset()
        }
    }
    
    // callback.
    
    private func handleAccelerometer(
        data: CMAccelerometerData?,
        e: Error?
    ) {
        if data == nil || e != nil {
            return
        }
        
        accelerometers[0] = data!.acceleration.x * gravity
        accelerometers[1] = data!.acceleration.y * gravity
        accelerometers[2] = data!.acceleration.z * gravity
    }
    
    private func handleDeviceMotion(
        motion: CMDeviceMotion?,
        e: Error?
    ) {
        if motion == nil || e != nil {
            return
        }
        
        userAccelerometers[0] = motion!.userAcceleration.x * gravity
        userAccelerometers[1] = motion!.userAcceleration.y * gravity
        userAccelerometers[2] = motion!.userAcceleration.z * gravity
        
        updateRotations()
    }
    
    private func updateRotations() {
        for i in 0 ..< 3 {
            if accelerometers[i] == nil
                || userAccelerometers[i] == nil {
                return
            }
            accelerometersOfGravity[i] = accelerometers[i]! - userAccelerometers[i]!
        }
        
        if let ax = accelerometersOfGravity[0],
           let ay = accelerometersOfGravity[1],
           let az = accelerometersOfGravity[2] {
            
            let g2d = sqrt(ax * ax + ay * ay)
            let g3d = sqrt(ax * ax + ay * ay + az * az)
            
            let cos2d = max(min(1.0, ay / g2d), -1)
            let cos3d = max(min(1.0, g2d / g3d), -1)
            
            var rotation2D = acos(cos2d) * (ax >= 0 ? 1 : -1) * 180.0 / Double.pi
            let rotation3D = acos(cos3d) * (az >= 0 ? 1 : -1) * 180.0 / Double.pi
            
            switch UIApplication
                .shared
                .windows
                .first?
                .windowScene?
                .interfaceOrientation {
            case .landscapeLeft:
                rotation2D += 90
                break
            
            case .landscapeRight:
                rotation2D -= 90
                break
                
            case .portraitUpsideDown:
                if (rotation2D > 0) {
                    rotation2D -= 180;
                } else {
                    rotation2D += 180;
                }
                break
                
            default:
                // do nothing.
                break
            }
            
            if rotation2D > 90 {
                rotation2D = 90 - (rotation2D - 90)
            } else if rotation2D < -90 {
                rotation2D = -90 - (90 + rotation2D)
            }
            
            rotation2D *= fabs(fabs(fabs(rotation3D) - 90.0) / 90.0)
            
            if self.rotation2D != rotation2D {
                self.rotation2D = rotation2D
            }
            if self.rotation3D != rotation3D {
                self.rotation3D = rotation3D
            }
        }
    }
}

// MARK: - interval computer.
class IntervalComputer {
    
    private var currentTime: TimeInterval
    private var lastUpdateTime: TimeInterval
    private var interval: TimeInterval
    
    var intervalInMillis: Int64 {
        get {
            return Int64(interval * 1000)
        }
    }
    
    private var _drawable: Bool
    var drawable: Bool {
        get {
            return _drawable
        }
        set(value) {
            if _drawable == value {
                return
            }
            
            _drawable = value
            if _drawable {
                reset()
            }
        }
    }
    
    internal init() {
        currentTime = -1
        lastUpdateTime = -1
        interval = 0
        
        _drawable = true
    }
    
    func reset() {
        currentTime = -1
        lastUpdateTime = -1
        interval = 0
    }
    
    func update() -> Int64 {
        if !drawable {
            return 0
        }
        
        currentTime = Date().timeIntervalSince1970
        interval = lastUpdateTime == -1 ? 0 : (currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        return intervalInMillis
    }
}

// MARK: - Rotation controller.
class DelayRotationController {
    
    private var targetRotation: Double
    private var currentRotation: Double
    private var velocity: Double
    private var acceleration: Double
    
    private static let DEFAULT_ABS_ACCELERATION = 90.0 / 200.0 / 800.0
    
    var rotation: Double {
        get {
            return currentRotation
        }
    }
    
    internal init(initRotation: Double) {
        targetRotation = DelayRotationController.getRotationInScope(
            rotation: initRotation
        )
        currentRotation = targetRotation
        velocity = 0
        acceleration = 0
    }
    
    func updateRotation(rotation: Double, interval: Int64) -> Double {
        targetRotation = DelayRotationController.getRotationInScope(
            rotation: rotation
        )
        
        if targetRotation == currentRotation {
            // don't need to move.
            acceleration = 0
            velocity = 0
            return self.rotation
        }
        
        var d = 0.0
        if velocity == 0 || (targetRotation - currentRotation) * velocity < 0 {
            // start or turn around.
            acceleration = (
                targetRotation > currentRotation ? 1 : -1
            ) * DelayRotationController.DEFAULT_ABS_ACCELERATION
            d = acceleration * pow(Double(interval), 2.0) / 2.0
            velocity = acceleration * Double(interval)
        } else if pow(fabs(velocity), 2.0) / (2 * DelayRotationController.DEFAULT_ABS_ACCELERATION) < fabs(targetRotation - currentRotation) {
            // speed up.
            acceleration = (
                targetRotation > currentRotation ? 1 : -1
            ) * DelayRotationController.DEFAULT_ABS_ACCELERATION
            d = velocity * Double(interval) + acceleration * pow(Double(interval), 2.0) / 2.0
            velocity += acceleration * Double(interval)
        } else {
            // slow down.
            acceleration = (
                targetRotation > currentRotation ? -1 : 1
            ) * pow(velocity, 2.0) / (
                2.0 * fabs(targetRotation - currentRotation)
            )
            d = velocity * Double(interval) + acceleration * pow(Double(interval), 2.0) / 2.0
            velocity += acceleration * Double(interval)
        }
        
        if fabs(d) > fabs(targetRotation - currentRotation) {
            acceleration = 0
            currentRotation = targetRotation
            velocity = 0
        } else {
            currentRotation += d
        }
        return self.rotation
    }

    // ensure the rotation value between -180 and 180.
    private static func getRotationInScope(rotation: Double) -> Double {
        if -180 <= rotation && rotation <= 180 {
            return rotation
        }
        
        var r = rotation
        while r < 0 {
            r += 180
        }
        return r.truncatingRemainder(dividingBy: 180.0)
    }
}
