//
//  CGRectExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/1.
//


import UIKit

public extension CGRect {
    
    static func from(center: CGPoint, size: CGSize) -> CGRect {
        return CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
