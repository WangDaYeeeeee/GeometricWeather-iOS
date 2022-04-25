//
//  CGAffineTransform.swift
//  
//
//  Created by 王大爷 on 2022/3/1.
//

import UIKit

public extension CGAffineTransform {
    
    var scale: Double {
        return sqrt(
            Double(self.a * self.a + self.c * self.c)
        )
    }
}
