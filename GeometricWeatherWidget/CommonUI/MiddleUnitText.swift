//
//  MiddleUnitText.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/17.
//

import SwiftUI

private func stringStartWithSign(_ string: String) -> Bool {
    return string.starts(with: "-")
    || string.starts(with: "<")
}

struct MiddleUnitText: View {
    
    let sign: String
    let number: String
    let unit: String
    let font: Font
    let textColor: Color
    
    init(
        value: String,
        unit: String,
        font: Font,
        textColor: Color
    ) {
        self.sign = stringStartWithSign(value)
        ? String(value.first ?? Character(""))
        : ""
        self.number = stringStartWithSign(value)
        ? String(value.dropFirst())
        : value
        self.unit = unit
        
        self.font = font
        self.textColor = textColor
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0.0) {
            ZStack(alignment: .trailing) {
                Text(self.sign).font(
                    self.font
                ).foregroundColor(
                    self.textColor
                )
                
                Text(self.unit).font(
                    self.font
                ).foregroundColor(
                    self.textColor
                ).opacity(0.0)
            }
            
            Text(self.number).font(
                self.font
            ).foregroundColor(
                self.textColor
            )
            
            ZStack(alignment: .leading) {
                Text(self.sign).font(
                    self.font
                ).foregroundColor(
                    self.textColor
                ).opacity(0.0)
                
                Text(self.unit).font(
                    self.font
                ).foregroundColor(
                    self.textColor
                )
            }
        }
    }
}

struct MiddleUnitText_Previews: PreviewProvider {
    static var previews: some View {
        MiddleUnitText(
            value: "-1",
            unit: "a",
            font: .title3,
            textColor: .black
        )
    }
}
