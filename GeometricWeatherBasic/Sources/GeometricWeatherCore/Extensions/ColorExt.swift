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

@available(iOS 14.0, *)
@available(watchOS 7.0, *)
@available(macOS 11.0, *)
public extension Color {
    
    var components: (
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat,
        opacity: CGFloat
    ) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        #if canImport(UIKit)
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        #elseif canImport(AppKit)
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        #endif

        return (r, g, b, o)
    }
    
    static func ColorFromRGB(_ rgbValue: Int) -> Color {
        let red =   Double((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rgbValue & 0x0000FF) / 0xFF
        return Color(red: red, green: green, blue: blue)
    }
    
    // compute.
    
    static func addColor(_ color1: Color, with color2: Color) -> Color {
        let (r1, g1, b1, a1) = color1.components
        let (r2, g2, b2, a2) = color2.components

        // add the components, but don't let them go above 1.0
        return Color(
            red: min(r1 + r2, 1),
            green: min(g1 + g2, 1),
            blue: min(b1 + b2, 1),
            opacity: (a1 + a2) / 2
        )
    }

    static func multiplyColor(_ color: Color, by multiplier: CGFloat) -> Color {
        let (r, g, b, a) = color.components
        return Color(
            red: r * multiplier,
            green: g * multiplier,
            blue: b * multiplier,
            opacity: a
        )
    }
    
    static func +(color1: Color, color2: Color) -> Color {
        return Self.addColor(color1, with: color2)
    }

    static func *(color: Color, multiplier: Double) -> Color {
        return Self.multiplyColor(color, by: CGFloat(multiplier))
    }
}
