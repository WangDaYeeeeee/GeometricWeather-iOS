//
//  HorizontalLinesBackgroundView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/15.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import SwiftUI

struct HorizontalLine: Identifiable {
    let id = UUID()
    
    let value: Double
    let leadingDescription: String
    let trailingDescription: String
}

class HorizontalLinesBackgroundView: UIView {
        
    // MARK: - properties.
    
    var highLines = [HorizontalLine]() {
        didSet {
            self.setNeedsLayout()
        }
    }
    var lowLines = [HorizontalLine]() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var lineColor: UIColor = .gray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var paddingTop = trendPaddingTop {
        didSet {
            self.setNeedsLayout()
        }
    }
    var paddingBottom = trendPaddingBottom {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: - subviews and sublayers cache.
    
    private var labelCache = Set<UILabel>()
    private var layerCache = Set<CAShapeLayer>()
    
    // MARK: - inner data.
    
    private var sizeCache = CGSize.zero
    
    // MARK: - life cycle.
    
    override func setNeedsLayout() {
        self.sizeCache = .zero
        super.setNeedsLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        if self.sizeCache == self.frame.size {
            return
        }
        self.sizeCache = self.frame.size
        
        for label in self.labelCache {
            label.removeFromSuperview()
        }
        self.labelCache.removeAll()
        
        for layer in self.layerCache {
            layer.removeFromSuperlayer()
        }
        self.layerCache.removeAll()
        
        for line in self.highLines {
            let layer = self.generateHorizontalLine(value: line.value)
            self.layer.addSublayer(layer)
            self.layerCache.insert(layer)
            
            self.bindLabel(line: line, isHighLine: true)
        }
        for line in self.lowLines {
            let layer = self.generateHorizontalLine(value: line.value)
            self.layer.addSublayer(layer)
            self.layerCache.insert(layer)
            
            self.bindLabel(line: line, isHighLine: false)
        }
    }
    
    // MARK: - ui.
    
    private func rtlX(_ x: CGFloat) -> CGFloat {
        return (self.isRtl ? (1.0 - x) : x) * self.frame.width
    }
    
    private func y(_ y: CGFloat) -> CGFloat {
        return self.frame.height - self.paddingBottom - y * (
            self.frame.height - self.paddingTop - self.paddingBottom
        )
    }
    
    private func generateHorizontalLine(value: Double) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = self.lineColor.cgColor
        layer.lineWidth = trendHorizontalLineWidth
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0), y: y(value)))
        path.addLine(to: CGPoint(x: rtlX(1), y: y(value)))
        layer.path = path.cgPath
        
        return layer
    }
    
    private func bindLabel(line: HorizontalLine, isHighLine: Bool) {
        let leadingLabel = self.generateLabel(text: line.leadingDescription)
        leadingLabel.center = CGPoint(x: rtlX(0.0), y: y(line.value))
        leadingLabel.center = CGPoint(
            x: leadingLabel.center.x + (self.isRtl ? -1 : 1) * (leadingLabel.frame.width * 0.5 + trendTextMargin),
            y: leadingLabel.center.y + (isHighLine ? -1 : 1) * (leadingLabel.frame.height * 0.5 + trendTextMargin)
        )
        self.addSubview(leadingLabel)
        self.labelCache.insert(leadingLabel)
        
        let trailingLabel = self.generateLabel(text: line.trailingDescription)
        trailingLabel.center = CGPoint(x: rtlX(1.0), y: y(line.value))
        trailingLabel.center = CGPoint(
            x: trailingLabel.center.x + (self.isRtl ? 1 : -1) * (trailingLabel.frame.width * 0.5 + trendTextMargin),
            y: trailingLabel.center.y + (isHighLine ? -1 : 1) * (trailingLabel.frame.height * 0.5 + trendTextMargin)
        )
        self.addSubview(trailingLabel)
        self.labelCache.insert(trailingLabel)
    }
    
    private func generateLabel(text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = text
        label.font = miniCaptionFont
        label.textColor = .tertiaryLabel
        label.frame = .zero
        label.sizeToFit()
        return label
    }
}

