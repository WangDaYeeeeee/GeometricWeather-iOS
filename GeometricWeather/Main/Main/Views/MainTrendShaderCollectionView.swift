//
//  MainTrendShaderCollectionView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/13.
//

import UIKit
import GeometricWeatherBasic

// MARK: - collection view.

class MainTrendShaderCollectionView: UICollectionView {
    
    private let scrollBar = MainTrendScrollBarView(frame: .zero)
    
    var cellSize: CGSize {
        get {
            return CGSize(
                width: self.frame.width / CGFloat(getTrenItemDisplayCount()),
                height: self.frame.height
            )
        }
    }
    
    // MARK: - life cycle.
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        self.scrollBar.isUserInteractionEnabled = true
        self.addSubview(scrollBar)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let subview = self.subviews.last {
            if subview != self.scrollBar {
                let scrollPercent = self.contentOffset.x / (
                    self.contentSize.width - self.frame.width
                )
                let scrollBarX = (
                    self.frame.width - subview.frame.width
                ) * scrollPercent
                
                self.scrollBar.frame = CGRect(
                    x: scrollBarX + self.contentOffset.x,
                    y: 0.0,
                    width: subview.frame.width,
                    height: self.frame.height
                )
                return
            }
        }
        self.scrollBar.frame = .zero
    }
}

// MARK: - scroll bar.

fileprivate class MainTrendScrollBarView: UICollectionReusableView {
    
    private let foregroundLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        
        self.foregroundLayer.locations = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.5),
            NSNumber(value: 1.0),
        ]
        self.foregroundLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.foregroundLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.addSublayer(self.foregroundLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.foregroundLayer.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.frame.width,
            height: self.frame.height
        )
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        DispatchQueue.main.async {
            self.setScrollBarColors()
        }
    }
    
    private func setScrollBarColors() {
        self.foregroundLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(
                self.traitCollection.userInterfaceStyle == .light ? 0.02 : 0.12
            ).cgColor,
            UIColor.clear.cgColor,
        ]
    }
}
