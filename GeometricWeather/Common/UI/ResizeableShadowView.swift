//
//  ResizeableShadowView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/16.
//

import Foundation
import GeometricWeatherBasic

class ResizeableShadowView: UIImageView {
    
    var shadow: Shadow
    var cornerRadius: CGFloat
    
    static let capsuleRadius: CGFloat = -1.0
    
    // fit for auto layout. this view's bound depends on the foregroung view.
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    init(frame: CGRect, shadow: Shadow, cornerRadius: CGFloat) {
        self.shadow = shadow
        self.cornerRadius = cornerRadius
        super.init(frame: frame)
        
        self.contentMode = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.image = .resizableShadowImage(
            withSize: self.bounds.size,
            cornerRadius: self.cornerRadius == Self.capsuleRadius
            ? min(self.bounds.width, self.bounds.height) / 2.0
            : self.cornerRadius,
            shadow: self.shadow
        )
    }
}
