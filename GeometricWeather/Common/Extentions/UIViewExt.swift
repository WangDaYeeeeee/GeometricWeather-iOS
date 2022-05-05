//
//  UIView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/15.
//

import UIKit

public extension UIView {
    
    var isRtl: Bool {
        get {
            if let language = (
                UserDefaults.standard.object(
                    forKey: "AppleLanguages"
                ) as? [String]
            )?.first {
                return language.hasPrefix("ar")
            }
            
            return false
        }
    }
}
