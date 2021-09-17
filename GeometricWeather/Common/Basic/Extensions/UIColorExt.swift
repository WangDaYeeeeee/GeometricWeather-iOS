//
//  ColorExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/15.
//

import UIKit

extension UIColor {
    
    // components.
    
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

        guard getRed(
            &r,
            green: &g,
            blue: &b,
            alpha: &o
        ) else {
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
    
    // generator.
    
    static func colorFromRGB(_ rgbValue: Int) -> UIColor {
        let red =   Double((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rgbValue & 0x0000FF) / 0xFF
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // compute.
    
    static func addColor(_ color1: UIColor, with color2: UIColor) -> UIColor {
        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // add the components, but don't let them go above 1.0
        return UIColor(
            red: min(r1 + r2, 1),
            green: min(g1 + g2, 1),
            blue: min(b1 + b2, 1),
            alpha: (a1 + a2) / 2
        )
    }

    static func multiplyColor(_ color: UIColor, by multiplier: CGFloat) -> UIColor {
        var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(
            red: r * multiplier,
            green: g * multiplier,
            blue: b * multiplier,
            alpha: a
        )
    }
    
    static func +(color1: UIColor, color2: UIColor) -> UIColor {
        return Self.addColor(color1, with: color2)
    }

    static func *(color: UIColor, multiplier: Double) -> UIColor {
        return Self.multiplyColor(color, by: CGFloat(multiplier))
    }
}
