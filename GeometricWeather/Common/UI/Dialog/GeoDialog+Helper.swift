//
//  GeoDialog+Helper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/1.
//

import UIKit

extension GeoDialog {
    
    func showSelf(inWindowOfView view: UIView) {
        if let window = view.window {
            self.showOn(window)
        }
    }
}
