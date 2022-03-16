//
//  TemperatureAndPrecipitationTrendView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/15.
//

import UIKit
import GeometricWeatherBasic

class PolylineAndHistogramView: UIView {
    
    // MARK: - data.
    
    // trend data.
    
    var highPolylineTrend: PolylineTrend? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowPolylineTrend: PolylineTrend? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var histogramValue: Double? {
        didSet {
            self.sizeCache = .zero
            self.histogramLabel.alpha = self.histogramValue == nil ? 0 : 1
            self.setNeedsLayout()
        }
    }
    
    // color.
    
    var highPolylineColor: UIColor {
        get {
            return UIColor(
                cgColor: self.highPolylineShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.highPolylineShape.strokeColor = newValue.cgColor
            self.highPolylineShape.shadowColor = newValue.cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowPolylineColor: UIColor {
        get {
            return UIColor(
                cgColor: self.lowPolylineShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.lowPolylineShape.strokeColor = newValue.cgColor
            self.lowPolylineShape.shadowColor = newValue.cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var histogramColor: UIColor {
        get {
            return UIColor(
                cgColor: self.histogramShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.histogramShape.strokeColor = newValue.withAlphaComponent(
                trendPrecipitationAlpha
            ).cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var highPolylineDescription: String {
        get {
            return self.highPolylineLabel.text ?? ""
        }
        set {
            self.setLabel(
                label: self.highPolylineLabel,
                text: newValue
            )
        }
    }
    var lowPolylineDescription: String {
        get {
            return self.lowPolylineLabel.text ?? ""
        }
        set {
            self.setLabel(
                label: self.lowPolylineLabel,
                text: newValue
            )
        }
    }
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
    
    let highPolylineLabel = UILabel(frame: .zero)
    let lowPolylineLabel = UILabel(frame: .zero)
    let histogramLabel = UILabel(frame: .zero)
    
    // MARK: - shapes.
    
    private let highPolylineShape = CAShapeLayer()
    private let lowPolylineShape = CAShapeLayer()
    private let histogramShape = CAShapeLayer()
    private let timelineShape = CAShapeLayer()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.layer.masksToBounds = true
        
        // subviews.
        
        self.highPolylineLabel.textColor = .label
        self.highPolylineLabel.font = .systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .bold
        )
        self.highPolylineLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.highPolylineLabel);
        
        self.lowPolylineLabel.textColor = .label.withAlphaComponent(0.5)
        self.lowPolylineLabel.font = .systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .bold
        )
        self.lowPolylineLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.lowPolylineLabel);
        
        self.histogramLabel.textColor = .secondaryLabel
        self.histogramLabel.font = miniCaptionFont
        self.histogramLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.histogramLabel);
        
        // sublayers.
        
        self.highPolylineShape.lineCap = .round
        self.highPolylineShape.lineWidth = trendPolylineWidth
        self.highPolylineShape.strokeColor = UIColor.systemBlue.cgColor
        self.highPolylineShape.fillColor = UIColor.clear.cgColor
        self.highPolylineShape.zPosition = trendPolylineZ
        self.highPolylineShape.shadowOffset = CGSize(width: 0, height: 1.0)
        self.highPolylineShape.shadowRadius = 2.0
        self.highPolylineShape.shadowOpacity = 0.5
        
        self.lowPolylineShape.lineCap = .round
        self.lowPolylineShape.lineWidth = trendPolylineWidth
        self.lowPolylineShape.strokeColor = UIColor.systemGreen.cgColor
        self.lowPolylineShape.fillColor = UIColor.clear.cgColor
        self.lowPolylineShape.zPosition = trendPolylineZ
        self.lowPolylineShape.shadowOffset = CGSize(width: 0, height: 1.0)
        self.lowPolylineShape.shadowRadius = 2.0
        self.lowPolylineShape.shadowOpacity = 0.5
        
        self.histogramShape.lineCap = .round
        self.histogramShape.lineWidth = trendHistogramWidth
        self.histogramShape.strokeColor = UIColor.systemYellow.cgColor
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
        self.highPolylineShape.removeFromSuperlayer()
        self.lowPolylineShape.removeFromSuperlayer()
        self.histogramShape.removeFromSuperlayer()
        
        // add shape layers.
        
        setTimelineShapeLayer(layer: self.timelineShape)
        self.layer.addSublayer(self.timelineShape)
        
        if let trend = self.highPolylineTrend {
            self.setPolylineShapeLayer(layer: self.highPolylineShape, trend: trend)
            self.layer.addSublayer(self.highPolylineShape)
        }
        if let trend = self.lowPolylineTrend {
            self.setPolylineShapeLayer(layer: self.lowPolylineShape, trend: trend)
            self.layer.addSublayer(self.lowPolylineShape)
        }
        if let value = self.histogramValue {
            self.setHistogramShapeLayer(layer: self.histogramShape, value: value)
            self.layer.addSublayer(self.histogramShape)
        }
        
        // subviews.
        
        if let trend = self.highPolylineTrend {
            self.highPolylineLabel.center = CGPoint(
                x: rtlX(0.5),
                y: y(trend.center) - self.highPolylineLabel.frame.height / 2 - trendTextMargin
            )
        }
        if let trend = self.lowPolylineTrend {
            self.lowPolylineLabel.center = CGPoint(
                x: rtlX(0.5),
                y: y(trend.center) + self.highPolylineLabel.frame.height / 2 + trendTextMargin
            )
        }
        if self.histogramValue != nil {
            self.histogramLabel.center = CGPoint(
                x: rtlX(0.5),
                y: y(0) + self.histogramLabel.frame.height * 1.25 + trendTextMargin
            )
        }
    }
    
    // MARK: - ui.
    
    private func setLabel(label: UILabel, text: String) {
        label.text = text
        label.isHidden = text.isEmpty
        label.sizeToFit()
    }
    
    private func setPolylineShapeLayer(layer: CAShapeLayer, trend: PolylineTrend) {
        let path = UIBezierPath()
        
        if trend.start != nil && trend.end != nil {
            // 0, start.
            path.move(to: CGPoint(x: rtlX(0.0), y: y(trend.start ?? 0)))
            // 0.5, center.
            path.addLine(to: CGPoint(x: rtlX(0.5), y: y(trend.center)))
            // 1, end.
            path.addLine(to: CGPoint(x: rtlX(1.0), y: y(trend.end ?? 0)))
        } else if trend.start != nil {
            // end == nil.
            // 0, start.
            path.move(to: CGPoint(x: rtlX(0.0), y: y(trend.start ?? 0)))
            // 0.5, center.
            path.addLine(to: CGPoint(x: rtlX(0.5), y: y(trend.center)))
        } else {
            // start == nil.
            // 0.5, center.
            path.move(to: CGPoint(x: rtlX(0.5), y: y(trend.center)))
            // 1, end.
            path.addLine(to: CGPoint(x: rtlX(1.0), y: y(trend.end ?? 0)))
        }
        
        layer.path = path.cgPath
        layer.shadowPath = path.cgPath.copy(
            strokingWithWidth: layer.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0
        )
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
