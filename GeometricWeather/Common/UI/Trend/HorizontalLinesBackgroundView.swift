//
//  HorizontalLinesBackgroundView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/15.
//

import UIKit
import GeometricWeatherBasic

class HorizontalLinesBackgroundView: UIView {
    
    // MARK: - data.
    
    // data.
    
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
    
    var highLineColor: UIColor {
        get {
            return UIColor(
                cgColor: self.highLineShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.highLineShape.strokeColor = newValue.withAlphaComponent(
                trendHorizontalLineAlpha
            ).cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowLineColor: UIColor {
        get {
            return UIColor(
                cgColor: self.lowLineShape.strokeColor ?? CGColor(
                    red: 0, green: 0, blue: 0, alpha: 0
                )
            )
        }
        set {
            self.lowLineShape.strokeColor = newValue.withAlphaComponent(
                trendHorizontalLineAlpha
            ).cgColor
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var highDescription: HorizontalLineDescription {
        get {
            return (
                self.highLeadingLabel.text ?? "",
                self.highTrailingLabel.text ?? ""
            )
        }
        set {
            self.setLabel(
                label: self.highLeadingLabel,
                text: newValue.leading
            )
            self.setLabel(
                label: self.highTrailingLabel,
                text: newValue.trailing
            )
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var lowDescription: HorizontalLineDescription {
        get {
            return (
                self.lowLeadingLabel.text ?? "",
                self.lowTrailingLabel.text ?? ""
            )
        }
        set {
            self.setLabel(
                label: self.lowLeadingLabel,
                text: newValue.leading
            )
            self.setLabel(
                label: self.lowTrailingLabel,
                text: newValue.trailing
            )
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // inner data.
    
    private var sizeCache = CGSize.zero
    
    // MARK: - subviews.
    
    private let highLeadingLabel = UILabel(frame: .zero)
    private let lowLeadingLabel = UILabel(frame: .zero)
    
    private let highTrailingLabel = UILabel(frame: .zero)
    private let lowTrailingLabel = UILabel(frame: .zero)
    
    // MARK: - shapes.
    
    private let highLineShape = CAShapeLayer()
    private let lowLineShape = CAShapeLayer()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // subviews.
        
        self.highLeadingLabel.textColor = .tertiaryLabel
        self.highLeadingLabel.font = miniCaptionFont
        self.highLeadingLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.highLeadingLabel);
        
        self.highTrailingLabel.textColor = .tertiaryLabel
        self.highTrailingLabel.font = miniCaptionFont
        self.highTrailingLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.highTrailingLabel);
        
        self.lowLeadingLabel.textColor = .tertiaryLabel
        self.lowLeadingLabel.font = miniCaptionFont
        self.lowLeadingLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.lowLeadingLabel);
        
        self.lowTrailingLabel.textColor = .tertiaryLabel
        self.lowTrailingLabel.font = miniCaptionFont
        self.lowTrailingLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.lowTrailingLabel);
        
        // sublayers.
        
        self.highLineShape.lineCap = .round
        self.highLineShape.lineWidth = trendHorizontalLineWidth
        self.highLineShape.strokeColor = UIColor.separator.withAlphaComponent(
            trendHorizontalLineAlpha
        ).cgColor
        self.highLineShape.fillColor = UIColor.clear.cgColor
        self.highLineShape.zPosition = trendTimelineZ
        self.layer.addSublayer(self.highLineShape)
        
        self.lowLineShape.lineCap = .round
        self.lowLineShape.lineWidth = trendHorizontalLineWidth
        self.lowLineShape.strokeColor = UIColor.separator.withAlphaComponent(
            trendHorizontalLineAlpha
        ).cgColor
        self.lowLineShape.fillColor = UIColor.clear.cgColor
        self.lowLineShape.zPosition = trendTimelineZ
        self.layer.addSublayer(self.lowLineShape)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if sizeCache == self.frame.size {
            return
        }
        sizeCache = self.frame.size
        
        // sublayers.
        
        // remove all shape layers.
        self.highLineShape.removeFromSuperlayer()
        self.lowLineShape.removeFromSuperlayer()
        
        // add shape layers.
        if let value = self.highValue {
            self.setHorizontalLineShapeLayer(layer: self.highLineShape, value: value)
            self.layer.addSublayer(self.highLineShape)
        }
        if let value = self.lowValue {
            self.setHorizontalLineShapeLayer(layer: self.lowLineShape, value: value)
            self.layer.addSublayer(self.lowLineShape)
        }
        
        // subviews.
        
        if let value = self.highValue {
            self.highLeadingLabel.center = CGPoint(
                x: rtlX(0),
                y: y(value) - self.highLeadingLabel.frame.height / 2 - trendTextMargin
            )
            self.alignEdge(label: self.highLeadingLabel)
            
            self.highTrailingLabel.center = CGPoint(
                x: rtlX(1),
                y: y(value) - self.highTrailingLabel.frame.height / 2 - trendTextMargin
            )
            self.alignEdge(label: self.highTrailingLabel)
        }
        if let value = self.lowValue {
            self.lowLeadingLabel.center = CGPoint(
                x: rtlX(0),
                y: y(value) + self.lowLeadingLabel.frame.height / 2 + trendTextMargin
            )
            self.alignEdge(label: self.lowLeadingLabel)
            
            self.lowTrailingLabel.center = CGPoint(
                x: rtlX(1),
                y: y(value) + self.lowTrailingLabel.frame.height / 2 + trendTextMargin
            )
            self.alignEdge(label: self.lowTrailingLabel)
        }
    }
    
    // MARK: - ui.
    
    private func setLabel(label: UILabel, text: String) {
        label.text = text
        label.isHidden = text.isEmpty
        label.sizeToFit()
    }
    
    private func setHorizontalLineShapeLayer(layer: CAShapeLayer, value: Double) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rtlX(0), y: y(value)))
        path.addLine(to: CGPoint(x: rtlX(1), y: y(value)))
        layer.path = path.cgPath
    }
    
    private func rtlX(_ x: CGFloat) -> CGFloat {
        return GeometricWeather.rtlX(x, width: self.frame.width, rtl: isRtl)
    }
    
    private func y(_ y: CGFloat) -> CGFloat {
        return GeometricWeather.y(y, height: self.frame.height)
    }
    
    private func alignEdge(label: UILabel) {
        if label.center.x < self.frame.width / 2 {
            label.frame.origin = CGPoint(
                x: trendTextMargin,
                y: label.frame.origin.y
            )
        } else {
            label.frame.origin = CGPoint(
                x: self.frame.width - label.frame.width - trendTextMargin,
                y: label.frame.origin.y
            )
        }
    }
}
