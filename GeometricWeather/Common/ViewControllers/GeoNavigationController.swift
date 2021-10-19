//
//  GeoNavigationController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

class GeoNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.isEnabled = true
        
        ThemeManager.shared.globalOverrideUIStyle.syncObserveValue(
            self.description
        ) { newValue in
            self.overrideUserInterfaceStyle = newValue
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return topViewController?.preferredStatusBarStyle ?? .default
    }
}
