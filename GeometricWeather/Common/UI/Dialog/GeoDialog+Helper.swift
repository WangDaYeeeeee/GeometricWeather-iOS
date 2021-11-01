//
//  GeoDialog+Helper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/1.
//

import Foundation

extension GeoDialog {
    
    func showSelf() {
        if let view = UIApplication.shared.keyWindowInCurrentScene {
            self.showOn(view)
        }
    }
}
