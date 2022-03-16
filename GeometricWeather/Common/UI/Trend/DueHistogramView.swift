//
//  DueHistogramView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/23.
//

import UIKit
import GeometricWeatherBasic

class DueHistogramView: UIView {
    
    // MARK: - data.
    
    // trend data.
    
    var highHistogramValue: Double? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowHistogramValue: Double? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // color.
    
    var highHistogramColor: UIColor {
        get {
            return UIColor(
                cgColor: self.highHistogramShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.highBackgroundShape.strokeColor = newValue.withAlphaComponent(
                trendHistogramBackgroundAlpha
            ).cgColor
            self.highHistogramShape.strokeColor = newValue.cgColor
            self.highHistogramShape.shadowColor = newValue.cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowHistogramColor: UIColor {
        get {
            return UIColor(
                cgColor: self.lowHistogramShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.lowBackgroundShape.strokeColor = newValue.withAlphaComponent(
                trendHistogramBackgroundAlpha
            ).cgColor
            self.lowHistogramShape.strokeColor = newValue.cgColor
            self.lowHistogramShape.shadowColor = newValue.cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var highHistogramDescription: String {
        get {
            return self.highHistogramLabel.text ?? ""
        }
        set {
            self.setLabel(
                label: self.highHistogramLabel,
                text: newValue
            )
        }
    }
    var lowHistogramDescription: String {
        get {
            return self.lowHistogramLabel.text ?? ""
        }
        set {
            self.setLabel(
                label: self.lowHistogramLabel,
                text: newValue
            )
        }
    }
    
    // inner data.
    
    private var sizeCache = CGSize.zero
    
    // MARK: - subviews.
    
    let highHistogramLabel = UILabel(frame: .zero)
    let lowHistogramLabel = UILabel(frame: .zero)
    let histogramLabel = UILabel(frame: .zero)
    
    // MARK: - shapes.
    
    private let highBackgroundShape = CAShapeLayer()
    private let highHistogramShape = CAShapeLayer()
    private let lowBackgroundShape = CAShapeLayer()
    private let lowHistogramShape = CAShapeLayer()
    private let timelineShape = CAShapeLayer()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // subviews.
        
        self.highHistogramLabel.textColor = .label
        self.highHistogramLabel.font = miniCaptionFont
        self.highHistogramLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.highHistogramLabel);
        
        self.lowHistogramLabel.textColor = .label
        self.lowHistogramLabel.font = miniCaptionFont
        self.lowHistogramLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.lowHistogramLabel);
        
        // sublayers.
        
        self.highBackgroundShape.lineCap = .round
        self.highBackgroundShape.lineWidth = trendHistogramWidth
        self.highBackgroundShape.strokeColor = UIColor.systemBlue.withAlphaComponent(
            trendHistogramBackgroundAlpha
        ).cgColor
        self.highBackgroundShape.fillColor = UIColor.clear.cgColor
        self.highBackgroundShape.zPosition = trendHistogramZ
        
        self.highHistogramShape.lineCap = .round
        self.highHistogramShape.lineWidth = trendHistogramWidth
        self.highHistogramShape.strokeColor = UIColor.systemBlue.withAlphaComponent(
            trendHistogramForegroundAlpha
        ).cgColor
        self.highHistogramShape.fillColor = UIColor.clear.cgColor
        self.highHistogramShape.zPosition = trendHistogramZ
        self.highHistogramShape.shadowOffset = CGSize(width: 0, height: 2.0)
        self.highHistogramShape.shadowRadius = 4.0
        self.highHistogramShape.shadowOpacity = 0.5
        
        self.lowBackgroundShape.lineCap = .round
        self.lowBackgroundShape.lineWidth = trendHistogramWidth
        self.lowBackgroundShape.strokeColor = UIColor.systemBlue.withAlphaComponent(
            trendHistogramBackgroundAlpha
        ).cgColor
        self.lowBackgroundShape.fillColor = UIColor.clear.cgColor
        self.lowBackgroundShape.zPosition = trendHistogramZ
        
        self.lowHistogramShape.lineCap = .round
        self.lowHistogramShape.lineWidth = trendHistogramWidth
        self.lowHistogramShape.strokeColor = UIColor.systemGreen.withAlphaComponent(
            trendHistogramForegroundAlpha
        ).cgColor
        self.lowHistogramShape.fillColor = UIColor.clear.cgColor
        self.lowHistogramShape.zPosition = trendHistogramZ
        self.lowHistogramShape.shadowOffset = CGSize(width: 0, height: 2.0)
        self.lowHistogramShape.shadowRadius = 4.0
        self.lowHistogramShape.shadowOpacity = 0.5
        
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
        self.highBackgroundShape.removeFromSuperlayer()
        self.highHistogramShape.removeFromSuperlayer()
        self.lowBackgroundShape.removeFromSuperlayer()
        self.lowHistogramShape.removeFromSuperlayer()
        
        // add shape layers.
        
        setTimelineShapeLayer(layer: self.timelineShape)
        self.layer.addSublayer(self.timelineShape)
        
        if let high = self.highHistogramValue {
            self.setHighHistogramShapeLayer(layer: self.highBackgroundShape, value: 1.0)
            self.layer.addSublayer(self.highBackgroundShape)
            self.setHighHistogramShapeLayer(layer: self.highHistogramShape, value: high)
            self.layer.addSublayer(self.highHistogramShape)
        }
        if let low = self.lowHistogramValue {
            self.setLowHistogramShapeLayer(layer: self.lowBackgroundShape, value: 1.0)
            self.layer.addSublayer(self.lowBackgroundShape)
            self.setLowHistogramShapeLayer(layer: self.lowHistogramShape, value: low)
            self.layer.addSublayer(self.lowHistogramShape)
        }
        
        // subviews.
        
        if let high = self.highHistogramValue {
            self.highHistogramLabel.center = CGPoint(
                x: rtlX(0.5),
                y: y(high) - self.highHistogramLabel.frame.height / 2 - trendTextMargin - trendHistogramWidth
            )
        }
        if let low = self.lowHistogramValue {
            self.lowHistogramLabel.center = CGPoint(
                x: rtlX(0.5),
                y: y(low) + self.highHistogramLabel.frame.height / 2 + trendTextMargin + trendHistogramWidth
            )
        }
    }
    
    // MARK: - ui.
    
    private func setLabel(label: UILabel, text: String) {
        label.text = text
        label.isHidden = text.isEmpty
        label.sizeToFit()
    }
    
    private func setHighHistogramShapeLayer(layer: CAShapeLayer, value: Double) {
        let offset = trendHistogramWidth / 2.0 - 1.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0.5), y: y(0.5) - offset))
        path.addLine(to: CGPoint(x: rtlX(0.5), y: y(value) - offset))
        
        layer.path = path.cgPath
        layer.shadowPath = path.cgPath.copy(
            strokingWithWidth: layer.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0
        )
    }
    
    private func setLowHistogramShapeLayer(layer: CAShapeLayer, value: Double) {
        let offset = trendHistogramWidth / 2.0 - 1.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0.5), y: y(0.5) + offset))
        path.addLine(to: CGPoint(x: rtlX(0.5), y: y(value) + offset))
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
