//
//  MainTrendShaderCollectionView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/13.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - collection view.

class MainTrendShaderCollectionView: UICollectionView {
    
    private let scrollBar = MainTrendScrollBarView(frame: .zero)
    private let scrollReactor = UISelectionFeedbackGenerator()
    
    var cellSize: CGSize {
        return CGSize(
            width: max(
                56.0,
                CGFloat(
                    // cut width as int value to avoid gaps between 2 contiguous cells.
                    Int(
                        self.frame.width / CGFloat(getTrenItemDisplayCount())
                    )
                )
            ),
            height: self.frame.height
        )
    }
    
    var highlightIndex: Int {
        let rtlCenterX = self.isRtl
        ? (self.contentSize.width - self.scrollBar.center.x)
        : self.scrollBar.center.x
        // center positon / step-width, then cut the above value as int value.
        return Int(
            rtlCenterX / (
                self.contentSize.width / Double(self.numberOfItems(inSection: 0))
            )
        )
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
        

        self.scrollBar.frame = CGRect(
            x: (self.frame.width - self.cellSize.width)
            * self.contentOffset.x / (self.contentSize.width - self.frame.width)
            + self.contentOffset.x,
            y: 0.0,
            width: self.cellSize.width,
            height: self.frame.height
        )
    }
    
    // MARK: - scrolling.
    
    func scrollAligmentlyToScrollBar(at index: IndexPath, animated: Bool) {
        let percent = (
            Double(index.row) / Double(
                max(
                    1,
                    self.numberOfItems(inSection: 0) - 1
                )
            )
        ).keepIn(range: 0...1)
        let rtlPercent = self.isRtl
        ? 1 - percent
        : percent
        
        self.setContentOffset(
            CGPoint(
                x: rtlPercent * (self.contentSize.width - self.frame.width),
                y: 0
            ),
            animated: animated
        )
        self.scrollReactor.selectionChanged()
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
            self.traitCollection.userInterfaceStyle == .light
            ? UIColor.black.withAlphaComponent(0.04).cgColor
            : UIColor.white.withAlphaComponent(0.04).cgColor,
            UIColor.clear.cgColor,
        ]
    }
}
