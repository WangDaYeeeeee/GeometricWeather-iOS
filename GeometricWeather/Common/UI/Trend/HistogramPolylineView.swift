//
//  HistogramPolylineView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/26.
//

import Foundation
import GeometricWeatherBasic

private let paddingTop = 0.0
private let paddingHorizontal = normalMargin

private let tickMarkCount = 5

class HistogramPolylineView: UIView {
    
    // MARK: - data.
    
    // polyline data.
    
    var polylineValues = [Double]() {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // color.
    
    var polylineColor: UIColor = .systemBlue {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var polylineDescriptionMapper: ((Double) -> String)? {
        didSet {
            // TODO: update ui.
        }
    }
    var beginTime: String {
        get {
            return self.beginTimeLabel.text ?? ""
        }
        set {
            self.beginTimeLabel.text = newValue
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var endTime: String {
        get {
            return self.endTimeLabel.text ?? ""
        }
        set {
            self.endTimeLabel.text = newValue
            
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // inner data.
    
    private var sizeCache = CGSize.zero
    
    // MARK: - subviews.
    
    let beginTimeLabel = UILabel(frame: .zero)
    let endTimeLabel = UILabel(frame: .zero)
    
    // MARK: - shapes.
    
    private var polylineShapes = [CAShapeLayer]()
    private let baselineShape = CAShapeLayer()
    private var tickMarkShapes = [CAShapeLayer]()
    
    // MARK: - life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // subviews.
        
        self.beginTimeLabel.textColor = .label
        self.beginTimeLabel.font = miniCaptionFont
        self.beginTimeLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.beginTimeLabel);
        
        self.endTimeLabel.textColor = .label
        self.endTimeLabel.font = miniCaptionFont
        self.endTimeLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.endTimeLabel);
        
        // sublayers.
        
        self.baselineShape.lineCap = .round
        self.baselineShape.lineWidth = trendTimelineWidth
        self.baselineShape.fillColor = UIColor.clear.cgColor
        self.baselineShape.lineDashPattern = [
            NSNumber(value: 4.0),
            NSNumber(value: 4.0)
        ]
        self.baselineShape.zPosition = trendTimelineZ
        
        for _ in 0 ..< tickMarkCount {
            let layer = CAShapeLayer()
            layer.zPosition = trendTimelineZ
            self.tickMarkShapes.append(layer)
        }
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
        
        self.baselineShape.removeFromSuperlayer()
        self.tickMarkShapes.forEach { item in
            item.removeFromSuperlayer()
        }
        self.polylineShapes.forEach { item in
            item.removeFromSuperlayer()
        }
        self.polylineShapes.removeAll()
        
        // add shape layers.
        
        // base line.
        self.baselineShape.strokeColor = self.polylineColor.cgColor
        
        let path = UIBezierPath()
        path.move(
            to: CGPoint(
                x: self.rtlX(0.0),
                y: self.y(0.0) + trendHistogramWidth / 2.0 + 2.0
            )
        )
        path.addLine(
            to: CGPoint(
                x: self.rtlX(1.0),
                y: self.y(0.0) + trendHistogramWidth / 2.0 + 2.0
            )
        )
        self.baselineShape.path = path.cgPath
        self.layer.addSublayer(self.baselineShape)
        
        // tick mark.
        for i in 0 ..< tickMarkCount {
            let shape = self.tickMarkShapes[i]
            shape.strokeColor = UIColor.clear.cgColor
            shape.fillColor = self.polylineColor.cgColor
            shape.path = UIBezierPath(
                arcCenter: CGPoint(
                    x: self.rtlX(CGFloat(i) / CGFloat(tickMarkCount - 1)),
                    y: self.y(0.0) + trendHistogramWidth / 2.0 + 2.0
                ),
                radius: trendHistogramWidth / 4.0,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            ).cgPath
            self.layer.addSublayer(shape)
        }
        
        // polyline.
        if self.polylineValues.count > 1 {
            let expectedValueCount = Int(
                (
                    self.frame.width - 2 * paddingHorizontal
                ) / (
                    trendHistogramWidth / 2.0 * 1.5
                )
            )
            for i in 0 ..< expectedValueCount {
                let x = Double(i) / Double(expectedValueCount - 1)
                let y = self.polylineValues[
                    Int(x * Double(self.polylineValues.count - 1))
                ]
                if y == 0 {
                    continue
                }
                
                let shape = CAShapeLayer()
                shape.lineCap = .round
                shape.lineWidth = trendHistogramWidth / 2.0
                shape.strokeColor = self.polylineColor.cgColor
                shape.fillColor = UIColor.clear.cgColor
                shape.zPosition = trendPolylineZ
                shape.shadowOffset = CGSize(width: 0, height: 1.0)
                shape.shadowRadius = 2.0
                shape.shadowOpacity = 0.5
                shape.shadowColor = self.polylineColor.cgColor
                
                let path = UIBezierPath()
                path.move(
                    to: CGPoint(
                        x: self.rtlX(x),
                        y: self.y(0)
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: self.rtlX(x),
                        y: self.y(y)
                    )
                )
                shape.path = path.cgPath
                shape.shadowPath = shape.path?.copy(
                    strokingWithWidth: shape.lineWidth,
                    lineCap: .round,
                    lineJoin: .miter,
                    miterLimit: 0.0
                )
                
                self.polylineShapes.append(shape)
                self.layer.addSublayer(shape)
            }
        }
        
        // subviews.
        
        self.beginTimeLabel.sizeToFit()
        self.endTimeLabel.sizeToFit()
        
        if isRtl {
            self.endTimeLabel.frame = CGRect(
                x: paddingHorizontal,
                y: self.y(0.0) + trendHistogramWidth / 2.0 + 6.0,
                width: self.beginTimeLabel.frame.width,
                height: self.beginTimeLabel.frame.height
            )
            self.beginTimeLabel.frame = CGRect(
                x: self.frame.width - paddingHorizontal - self.endTimeLabel.frame.width,
                y: self.y(0.0) + trendHistogramWidth / 2.0 + 6.0,
                width: self.endTimeLabel.frame.width,
                height: self.endTimeLabel.frame.height
            )
        } else {
            self.beginTimeLabel.frame = CGRect(
                x: paddingHorizontal,
                y: self.y(0.0) + trendHistogramWidth / 2.0 + 6.0,
                width: self.beginTimeLabel.frame.width,
                height: self.beginTimeLabel.frame.height
            )
            self.endTimeLabel.frame = CGRect(
                x: self.frame.width - paddingHorizontal - self.endTimeLabel.frame.width,
                y: self.y(0.0) + trendHistogramWidth / 2.0 + 6.0,
                width: self.endTimeLabel.frame.width,
                height: self.endTimeLabel.frame.height
            )
        }
    }
    
    // MARK: - ui.
    
    private func rtlX(_ x: CGFloat) -> CGFloat {
        let len = (self.frame.width - 2 * paddingHorizontal) * x
        
        return self.isRtl ? (
            self.frame.width - paddingHorizontal - len
        ) : (
            paddingHorizontal + len
        )
    }
    
    private func y(_ y: CGFloat) -> CGFloat {
        return self.frame.height - trendPaddingBottom - y * (
            self.frame.height - paddingTop - trendPaddingBottom
        )
    }
}
