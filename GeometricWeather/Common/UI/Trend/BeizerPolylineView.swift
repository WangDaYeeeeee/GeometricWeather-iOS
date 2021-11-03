//
//  BeizerPolylineView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/26.
//

import Foundation
import GeometricWeatherBasic

private let paddingTop = 0.0
private let paddingHorizontal = normalMargin

class BeizerPolylineView: UIView {
    
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
        
        self.polylineShapes.forEach { item in
            item.removeFromSuperlayer()
        }
        self.polylineShapes.removeAll()
        self.baselineShape.removeFromSuperlayer()
        
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
        
        return isRtl ? (
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