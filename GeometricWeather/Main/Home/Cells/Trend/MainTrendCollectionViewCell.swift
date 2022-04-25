//
//  MainTrendCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/4/23.
//

import Foundation

protocol MainTrendPaddingContainer: MainTrendCollectionViewCell {
    
    var trendPaddingTop: CGFloat { get set }
    var trendPaddingBottom: CGFloat { get set }
}

class MainTrendCollectionViewCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            if (self.isHighlighted) {
                self.contentView.layer.removeAllAnimations()
                self.contentView.alpha = 0.5
            } else {
                self.contentView.layer.removeAllAnimations()
                UIView.animate(
                    withDuration: 0.45,
                    delay: 0.0,
                    options: [.allowUserInteraction, .beginFromCurrentState]
                ) {
                    self.contentView.alpha = 1.0
                } completion: { _ in
                    // do nothing.
                }
            }
        }
    }
}
