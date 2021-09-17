//
//  StringExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation

extension String {
    
    func isZipCode() -> Bool {
        return NSPredicate(
            format: "SELF MATCHES %@", "[a-zA-Z0-9]*"
        ).evaluate(
            with: self
        )
    }
    
    func toAttributedString(
        withLineSpaceing lineSpaceing: CGFloat
    ) -> NSAttributedString {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceing
        
        return NSAttributedString(
            string: self,
            attributes: [
                NSAttributedString.Key.paragraphStyle: style,
            ]
        )
    }
}
