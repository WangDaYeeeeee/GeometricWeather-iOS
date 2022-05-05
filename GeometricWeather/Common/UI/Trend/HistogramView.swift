//
//  TemperatureAndPrecipitationTrendView.swift
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

class HistogramView: UIView {
    
    // MARK: - data.
    
    // trend data.
    
    var highValue: Double? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowValue: Double? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // color.
    
    var color: UIColor {
        get {
            return UIColor(
                cgColor: self.histogramShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.histogramShape.strokeColor = newValue.cgColor
            self.histogramShape.shadowColor = newValue.cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var highDescription: (value: String, unit: String)? {
        get {
            return self.highLabel.text
        }
        set {
            self.setLabel(
                label: self.highLabel,
                value: newValue
            )
        }
    }
    var lowDescription: (value: String, unit: String)? {
        get {
            return self.lowLabel.text
        }
        set {
            self.setLabel(
                label: self.lowLabel,
                value: newValue
            )
        }
    }
    var bottomDescription: (value: String, unit: String)? {
        get {
            return self.bottomLabel.text
        }
        set {
            self.setLabel(
                label: self.bottomLabel,
                value: newValue
            )
        }
    }
    
    // layout.
    
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
    
    // inner data.
    
    private var sizeCache = CGSize.zero
    
    // MARK: - subviews.
    
    let highLabel = MiddleUnitLabel(frame: .zero)
    let lowLabel = MiddleUnitLabel(frame: .zero)
    let bottomLabel = MiddleUnitLabel(frame: .zero)
    
    // MARK: - shapes.
    
    private let histogramShape = CAShapeLayer()
    private let timelineShape = CAShapeLayer()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // subviews.
        
        self.highLabel.textColor = .label
        self.highLabel.font = .systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .bold
        )
        self.highLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.highLabel);
        
        self.lowLabel.textColor = .label.withAlphaComponent(0.5)
        self.lowLabel.font = .systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .bold
        )
        self.lowLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.lowLabel);
        
        self.bottomLabel.textColor = .secondaryLabel
        self.bottomLabel.font = miniCaptionFont
        self.bottomLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.bottomLabel);
        
        // sublayers.
        
        self.histogramShape.lineCap = .round
        self.histogramShape.lineWidth = trendHistogramWidth
        self.histogramShape.strokeColor = UIColor.systemYellow.cgColor
        self.histogramShape.fillColor = UIColor.clear.cgColor
        self.histogramShape.zPosition = trendHistogramZ
        self.histogramShape.shadowOffset = CGSize(width: 0, height: 4.0)
        self.histogramShape.shadowRadius = 6.0
        self.histogramShape.shadowOpacity = 0.5
        
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
        self.histogramShape.removeFromSuperlayer()
        
        // add shape layers.
        
        setTimelineShapeLayer(layer: self.timelineShape)
        self.layer.addSublayer(self.timelineShape)
        
        if let highValue = self.highValue {
            self.setHistogramShapeLayer(
                layer: self.histogramShape,
                highValue: highValue,
                lowValue: self.lowValue
            )
            self.layer.addSublayer(self.histogramShape)
        }
        
        // subviews.
        
        self.highLabel.center = CGPoint(
            x: rtlX(0.5),
            y: y(self.highValue ?? 0.0)
            - self.highLabel.frame.height / 2.0
            - trendTextMargin
            - trendHistogramWidth / 2.0
        )
        
        self.lowLabel.center = CGPoint(
            x: rtlX(0.5),
            y: y(self.lowValue ?? 0.0)
            + self.highLabel.frame.height / 2.0
            + trendTextMargin
            + trendHistogramWidth / 2.0
        )
        
        self.bottomLabel.center = CGPoint(
            x: rtlX(0.5),
            y: y(0)
            + (self.lowValue == nil ? 0 : self.highLabel.frame.height)
            + trendTextMargin
            + self.bottomLabel.frame.height / 2.0
            + trendHistogramWidth / 2.0
        )
    }
    
    // MARK: - ui.
    
    private func setLabel(label: MiddleUnitLabel, value: (value: String, unit: String)?) {
        label.text = value
        label.sizeToFit()
        self.setNeedsLayout()
    }
    
    private func setHistogramShapeLayer(
        layer: CAShapeLayer,
        highValue: Double,
        lowValue: Double?
    ) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0.5), y: y(highValue)))
        path.addLine(to: CGPoint(x: rtlX(0.5), y: y(lowValue ?? 0.0)))
        layer.path = path.cgPath
        
        layer.shadowPath = path.cgPath.copy(
            strokingWithWidth: layer.lineWidth,
            lineCap: .round,
            lineJoin: .miter,
            miterLimit: 0.0
        )
    }
    
    private func setTimelineShapeLayer(layer: CAShapeLayer) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0.5), y: self.paddingTop))
        path.addLine(to: CGPoint(x: rtlX(0.5), y: self.frame.height - self.paddingBottom))
        layer.path = path.cgPath
    }
    
    private func rtlX(_ x: CGFloat) -> CGFloat {
        return (self.isRtl ? (1.0 - x) : x) * self.frame.width
    }
    
    private func y(_ y: CGFloat) -> CGFloat {
        return self.frame.height - self.paddingBottom - y * (
            self.frame.height - self.paddingTop - self.paddingBottom
        )
    }
}
