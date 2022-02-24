//
//  HistogramView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/23.
//

import UIKit
import GeometricWeatherBasic

class HistogramView: UIView {
    
    // MARK: - data.
    
    // trend data.
    
    var histogramValue: Double? {
        didSet {
            self.sizeCache = .zero
            self.histogramLabel.alpha = self.histogramValue == nil ? 0 : 1
            self.setNeedsLayout()
        }
    }
    
    // color.
    
    var histogramColor: UIColor {
        get {
            return UIColor(
                cgColor: self.histogramShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.backgroundShape.strokeColor = newValue.withAlphaComponent(
                trendHistogramBackgroundAlpha
            ).cgColor
            self.histogramShape.strokeColor = newValue.withAlphaComponent(
                trendHistogramForegroundAlpha
            ).cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var histogramDescription: String {
        get {
            return self.histogramLabel.text ?? ""
        }
        set {
            self.setLabel(
                label: self.histogramLabel,
                text: newValue
            )
        }
    }
    
    // inner data.
    
    private var sizeCache = CGSize.zero
    
    // MARK: - subviews.
    
    let histogramLabel = UILabel(frame: .zero)
    
    // MARK: - shapes.
    
    private let backgroundShape = CAShapeLayer()
    private let histogramShape = CAShapeLayer()
    private let timelineShape = CAShapeLayer()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // subviews.
        
        self.histogramLabel.textColor = .label
        self.histogramLabel.font = miniCaptionFont
        self.histogramLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.histogramLabel);
        
        // sublayers.
        
        self.backgroundShape.lineCap = .round
        self.backgroundShape.lineWidth = trendHistogramWidth
        self.backgroundShape.strokeColor = UIColor.systemYellow.withAlphaComponent(
            trendHistogramBackgroundAlpha
        ).cgColor
        self.backgroundShape.fillColor = UIColor.clear.cgColor
        self.backgroundShape.zPosition = trendHistogramZ
        
        self.histogramShape.lineCap = .round
        self.histogramShape.lineWidth = trendHistogramWidth
        self.histogramShape.strokeColor = UIColor.systemYellow.withAlphaComponent(
            trendHistogramForegroundAlpha
        ).cgColor
        self.histogramShape.fillColor = UIColor.clear.cgColor
        self.histogramShape.zPosition = trendHistogramZ
        
        self.timelineShape.lineCap = .round
        self.timelineShape.lineWidth = trendTimelineWidth
        self.timelineShape.strokeColor = UIColor.gray.withAlphaComponent(
            trendTimelineAlpha
        ).cgColor
        self.timelineShape.fillColor = UIColor.clear.cgColor
        self.timelineShape.zPosition = trendTimelineZ
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if sizeCache == self.frame.size {
            return
        }
        sizeCache = self.frame.size
        
        // remove all shape layers.
        
        self.timelineShape.removeFromSuperlayer()
        self.backgroundShape.removeFromSuperlayer()
        self.histogramShape.removeFromSuperlayer()
        
        // add shape layers.
        
        setTimelineShapeLayer(layer: self.timelineShape)
        self.layer.addSublayer(self.timelineShape)
        
        if let value = self.histogramValue {
            self.setHistogramShapeLayer(layer: self.backgroundShape, value: 1.0)
            self.layer.addSublayer(self.backgroundShape)
            self.setHistogramShapeLayer(layer: self.histogramShape, value: value)
            self.layer.addSublayer(self.histogramShape)
        }
        
        // subviews.
        
        if self.histogramValue != nil {
            self.histogramLabel.center = CGPoint(
                x: rtlX(0.5),
                y: y(0) + self.histogramLabel.frame.height / 2 + trendTextMargin + trendHistogramWidth
            )
        }
    }
    
    // MARK: - ui.
    
    private func setLabel(label: UILabel, text: String) {
        label.text = text
        label.isHidden = text.isEmpty
        label.sizeToFit()
    }
    
    private func setHistogramShapeLayer(layer: CAShapeLayer, value: Double) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0.5), y: y(0)))
        path.addLine(to: CGPoint(x: rtlX(0.5), y: y(value)))
        layer.path = path.cgPath
    }
    
    private func setTimelineShapeLayer(layer: CAShapeLayer) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0.5), y: trendPaddingTop))
        path.addLine(to: CGPoint(x: rtlX(0.5), y: self.frame.height - trendPaddingBottom))
        layer.path = path.cgPath
    }
    
    private func rtlX(_ x: CGFloat) -> CGFloat {
        return GeometricWeather.rtlX(x, width: self.frame.width, rtl: isRtl)
    }
    
    private func y(_ y: CGFloat) -> CGFloat {
        return GeometricWeather.y(y, height: self.frame.height)
    }
}
