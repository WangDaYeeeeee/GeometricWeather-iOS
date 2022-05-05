//
//  StringExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/5/5.
//

import UIKit

public extension String {
    
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
