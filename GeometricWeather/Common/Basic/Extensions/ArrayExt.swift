//
//  ArrayExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/16.
//

import Foundation

extension Array {
    
    func get(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
