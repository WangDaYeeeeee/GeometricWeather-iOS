//
//  ColorExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/6.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    
    var components: (
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat,
        opacity: CGFloat
    ) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(
            &r,
            green: &g,
            blue: &b,
            alpha: &o
        ) else {
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
    
    static func ColorFromRGB(_ rgbValue: Int) -> Color {
        let red =   Double((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rgbValue & 0x0000FF) / 0xFF
        return Color(red: red, green: green, blue: blue)
    }
}
