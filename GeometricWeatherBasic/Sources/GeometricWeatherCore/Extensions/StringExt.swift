//
//  StringExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation

public extension String {
    
    func isZipCode() -> Bool {
        return NSPredicate(
            format: "SELF MATCHES %@", "[a-zA-Z0-9]*"
        ).evaluate(
            with: self
        )
    }
}
