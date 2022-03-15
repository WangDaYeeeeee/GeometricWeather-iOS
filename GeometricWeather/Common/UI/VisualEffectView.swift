//
//  VisualEffectView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/11.
//

import Foundation
import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    
    typealias UIViewType = UIVisualEffectView
    
    let effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: self.effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = self.effect
    }
}
