//
//  UIImageExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/29.
//

import Foundation

extension UIImage {
    
    func scaleToSize(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
