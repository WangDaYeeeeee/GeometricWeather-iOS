//
//  UIImageExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/29.
//

import UIKit

public extension UIImage {
    
    func scaleToSize(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public struct Shadow {
    public let offset: CGSize
    public let blur: CGFloat
    public let color: UIColor
    
    public init(
        offset: CGSize,
        blur: CGFloat,
        color: UIColor
    ) {
        self.offset = offset
        self.blur = blur
        self.color = color
    }
}

public extension UIImage {

    static func resizableShadowImage(
        withSize size: CGSize,
        cornerRadius: CGFloat,
        shadow: Shadow
    ) -> UIImage {
        let graphicContextSize = CGSize(
            width: size.width + (shadow.blur * 2.0),
            height: size.height + (shadow.blur * 2.0)
        )

        // Note: the image is transparent
        UIGraphicsBeginImageContextWithOptions(graphicContextSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        defer {
            UIGraphicsEndImageContext()
        }

        let roundedRect = CGRect(x: shadow.blur, y: shadow.blur, width: size.width, height: size.height)
        let shadowPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        let color = shadow.color.cgColor

        // Cut out the middle
        context.addRect(context.boundingBoxOfClipPath)
        context.addPath(shadowPath.cgPath)
        context.clip(using: .evenOdd)

        context.setStrokeColor(color)
        context.addPath(shadowPath.cgPath)
        context.setShadow(offset: shadow.offset, blur: shadow.blur, color: color)
        context.fillPath()

        let capInset = cornerRadius + shadow.blur
        let edgeInsets = UIEdgeInsets(top: capInset, left: capInset, bottom: capInset, right: capInset)
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        return image.resizableImage(withCapInsets: edgeInsets, resizingMode: .tile)
    }
}
