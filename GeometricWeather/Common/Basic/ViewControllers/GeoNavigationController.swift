//
//  GeoNavigationController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit

class GeoNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent = true
        self.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return topViewController?.preferredStatusBarStyle ?? .default
    }
}
