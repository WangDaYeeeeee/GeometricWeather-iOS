//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/6/16.
//

import Foundation
import UIKit
import SwiftUI

public extension UIImage {
    
    func resize(to targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func toImage() -> Image {
        return Image(uiImage: self)
    }
}
