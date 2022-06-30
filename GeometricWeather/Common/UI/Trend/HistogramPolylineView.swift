//
//  HistogramPolylineView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/26.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let paddingTop = 0.0
private let paddingHorizontal = normalMargin

private let tickMarkCount = 5

private let polylineWidth = trendHistogramWidth / 2.0
private let polylineMargin = trendHistogramWidth / 8.0

private let highlightAnimationDuration = 0.3
private let highlightProgressDeltaY = 3.0

private struct PolylineElement {
    let shape: CAShapeLayer
    let top: CGPoint
}

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
    
    var baselineColor: UIColor = .secondaryLabel {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var polylineColor: (Double) -> UIColor = { value in
        return .systemBlue
    } {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    var polylineTintColor: UIColor = .systemBlue {
        didSet {
            self.dragIndicator.backgroundColor = self.polylineTintColor
            self.sizeCache = .zero
            self.setNeedsLayout()
        }
    }
    
    // text.
    
    var polylineDescriptionMapper: ((Double) -> String)? {
        didSet {
            self.sizeCache = .zero
            self.setNeedsLayout()
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
    var centerTime: String {
        get {
            return self.centerTimeLabel.text ?? ""
        }
        set {
            self.centerTimeLabel.text = newValue
            
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
    
    // layout.
    
    private var sizeCache = CGSize.zero
    private var expectedValueCount = 100
    
    // gesture.
        
    private var isTouching = false
    private var isDragging = false
    private var isHorizontalDragging = false
    
    private var currentHighlightIndex: Int? = nil
    
    // MARK: - subviews.
    
    let beginTimeLabel = UILabel(frame: .zero)
    let centerTimeLabel = UILabel(frame: .zero)
    let endTimeLabel = UILabel(frame: .zero)
    
    private let dragIndicator = CornerButton(frame: .zero, useLittleMargin: true)
    
    // MARK: - shapes.
    
    private var polylineElements = [PolylineElement]()
    private let baselineShape = CAShapeLayer()
    private var tickMarkShapes = [CAShapeLayer]()
    
    // MARK: - reactor.
    
    private let dragSwitchImpactor = UIImpactFeedbackGenerator(style: .soft)
    
    // MARK: - init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        // subviews.
        
        self.beginTimeLabel.textColor = .label
        self.beginTimeLabel.font = miniCaptionFont
        self.beginTimeLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.beginTimeLabel)
        
        self.centerTimeLabel.textColor = .label
        self.centerTimeLabel.font = miniCaptionFont
        self.centerTimeLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.centerTimeLabel)
        
        self.endTimeLabel.textColor = .label
        self.endTimeLabel.font = miniCaptionFont
        self.endTimeLabel.layer.zPosition = trendSubviewsZ
        self.addSubview(self.endTimeLabel)
        
        self.dragIndicator.titleLabel?.font = .systemFont(
            ofSize: miniCaptionFont.pointSize,
            weight: .semibold
        )
        self.dragIndicator.setTitleColor(.white, for: .normal)
        self.dragIndicator.backgroundColor = self.polylineTintColor
        self.addSubview(self.dragIndicator)
        
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
    
    // MARK: - layout.
    
    override func layoutSubviews() {
        if self.sizeCache == self.frame.size {
            return
        }
        self.sizeCache = self.frame.size
        self.currentHighlightIndex = nil
        self.isDragging = false
        
        // remove all shape layers.
        
        self.baselineShape.removeFromSuperlayer()
        self.tickMarkShapes.forEach { item in
            item.removeFromSuperlayer()
        }
        self.polylineElements.forEach { element in
            element.shape.removeAllAnimations()
            element.shape.removeFromSuperlayer()
        }
        self.polylineElements.removeAll()
        
        // reset indicator.
        self.dragIndicator.layer.removeAllAnimations()
        self.dragIndicator.alpha = 0.0
        
        // add shape layers.
        
        // base line.
        self.baselineShape.strokeColor = self.baselineColor.cgColor
        
        let path = UIBezierPath()
        path.move(
            to: CGPoint(
                x: self.getLayoutRtlX(0.0),
                y: self.getLayoutY(0.0) + polylineWidth + 2.0
            )
        )
        path.addLine(
            to: CGPoint(
                x: self.getLayoutRtlX(1.0),
                y: self.getLayoutY(0.0) + polylineWidth + 2.0
            )
        )
        self.baselineShape.path = path.cgPath
        self.layer.addSublayer(self.baselineShape)
        
        // tick mark.
        for i in 0 ..< tickMarkCount {
            let shape = self.tickMarkShapes[i]
            shape.strokeColor = UIColor.clear.cgColor
            shape.fillColor = self.baselineColor.cgColor
            shape.path = UIBezierPath(
                arcCenter: CGPoint(
                    x: self.getLayoutRtlX(CGFloat(i) / CGFloat(tickMarkCount - 1)),
                    y: self.getLayoutY(0.0) + polylineWidth + 2.0
                ),
                radius: polylineWidth / 2.0,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            ).cgPath
            self.layer.addSublayer(shape)
        }
        
        // polyline.
        if self.polylineValues.count > 1 {
            self.expectedValueCount = Int(
                (
                    self.frame.width - 2 * paddingHorizontal
                ) / (
                    polylineWidth + 2 * polylineMargin
                )
            )
            for i in 0 ..< self.expectedValueCount {
                let x = Double(i) / Double(self.expectedValueCount - 1)
                let y = self.polylineValues[
                    Int(x * Double(self.polylineValues.count - 1))
                ]
                if y == 0 {
                    continue
                }
                
                let top = CGPoint(x: x, y: y)
                let color = self.polylineColor(y)
                
                let shape = CAShapeLayer()
                shape.lineCap = .round
                shape.lineWidth = polylineWidth
                shape.strokeColor = color.cgColor
                shape.fillColor = UIColor.clear.cgColor
                shape.zPosition = trendPolylineZ
                shape.shadowOffset = CGSize(width: 0, height: 1.0)
                shape.shadowRadius = 2.0
                shape.shadowOpacity = 0.5
                shape.shadowColor = color.cgColor
                
                shape.path = self.getPolylinePath(by: top).cgPath
                shape.shadowPath = shape.path?.copy(
                    strokingWithWidth: shape.lineWidth,
                    lineCap: .round,
                    lineJoin: .miter,
                    miterLimit: 0.0
                )
                                
                self.polylineElements.append(
                    PolylineElement(shape: shape, top: top)
                )
                self.layer.addSublayer(shape)
            }
        }
        
        // subviews.
        
        self.beginTimeLabel.frame = .zero
        self.centerTimeLabel.frame = .zero
        self.endTimeLabel.frame = .zero
        
        self.beginTimeLabel.sizeToFit()
        self.centerTimeLabel.sizeToFit()
        self.endTimeLabel.sizeToFit()
        
        if isRtl {
            self.endTimeLabel.frame = CGRect(
                x: paddingHorizontal,
                y: self.getLayoutY(0.0) + polylineWidth + 6.0,
                width: self.beginTimeLabel.frame.width,
                height: self.beginTimeLabel.frame.height
            )
            self.beginTimeLabel.frame = CGRect(
                x: self.frame.width - paddingHorizontal - self.endTimeLabel.frame.width,
                y: self.getLayoutY(0.0) + polylineWidth + 6.0,
                width: self.beginTimeLabel.frame.width,
                height: self.beginTimeLabel.frame.height
            )
        } else {
            self.beginTimeLabel.frame = CGRect(
                x: paddingHorizontal,
                y: self.getLayoutY(0.0) + polylineWidth + 6.0,
                width: self.beginTimeLabel.frame.width,
                height: self.beginTimeLabel.frame.height
            )
            self.endTimeLabel.frame = CGRect(
                x: self.frame.width - paddingHorizontal - self.endTimeLabel.frame.width,
                y: self.getLayoutY(0.0) + polylineWidth + 6.0,
                width: self.endTimeLabel.frame.width,
                height: self.endTimeLabel.frame.height
            )
        }
        self.centerTimeLabel.frame = CGRect(
            x: (self.frame.width - 2 * paddingHorizontal) / 2.0
            + paddingHorizontal
            - self.centerTimeLabel.frame.width / 2.0,
            y: self.getLayoutY(0.0) + polylineWidth + 6.0,
            width: self.centerTimeLabel.frame.width,
            height: self.centerTimeLabel.frame.height
        )
    }
    
    private func getPolylinePath(by top: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(
            to: CGPoint(
                x: self.getLayoutRtlX(top.x),
                y: self.getLayoutY(0)
            )
        )
        path.addLine(
            to: CGPoint(
                x: self.getLayoutRtlX(top.x),
                y: self.getLayoutY(top.y)
            )
        )
        return path
    }
    
    private func getLayoutRtlX(_ x: CGFloat) -> CGFloat {
        let len = (self.frame.width - 2 * paddingHorizontal) * x
        
        return self.isRtl ? (
            self.frame.width - paddingHorizontal - len
        ) : (
            paddingHorizontal + len
        )
    }
    
    private func getLayoutY(_ y: CGFloat) -> CGFloat {
        return self.frame.height - trendPaddingBottom - y * (
            self.frame.height - paddingTop - trendPaddingBottom
        )
    }
    
    // MARK: - gesture.
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return paddingTop < point.y && point.y < self.frame.height - trendPaddingBottom
    }
    
    override func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // return true if user is we are not tracking user's touching.
        if !self.isTouching {
            return true
        }
        // return false if we have already detected that user is dragging horizontally.
        if self.isDragging && self.isHorizontalDragging {
            return false
        }
        // if user is dragging.
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gesture.translation(in: self)
            if abs(translation.x) < abs(translation.y) {
                // user is dragging vertically, return true to let superview consume scroll event.
                return true
            } else {
                // user is dragging horizontally,
                // return true if we have already detected that user has dragged vertically,
                return self.isDragging && !self.isHorizontalDragging
            }
        }
        // otherwise, return true.
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false
        self.isHorizontalDragging = false
        
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            
            // we won't to track user's touching if the first touch is not on a polyline.
            self.isTouching = self.indexPolyline(by: touchPoint) != nil
            if self.isTouching {
                self.highlightPolyline(to: touchPoint)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isTouching {
            super.touchesMoved(touches, with: event)
            return
        }
        
        // only check drag distance at the first moving.
        if !self.isDragging {
            self.isDragging = true
            
            if let touch = touches.first {
                let currPoint = touch.location(in: self)
                let prevPoint = touch.previousLocation(in: self)
                self.isHorizontalDragging = abs(currPoint.x - prevPoint.x) > abs(currPoint.y - prevPoint.y)
            } else {
                self.isHorizontalDragging = false
                // dragging vertically,
                // we need cancel highlight status and pass touch events to the next responder.
                self.highlightPolyline(to: nil)
            }
        }
        
        if !self.isHorizontalDragging {
            super.touchesMoved(touches, with: event)
            return
        }
        
        if let touch = touches.first {
            self.highlightPolyline(to: touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isTouching {
            
            self.isDragging = false
            self.isHorizontalDragging = false
            
            super.touchesEnded(touches, with: event)
            return
        }
        
        if !self.isDragging || !self.isHorizontalDragging {
            super.touchesEnded(touches, with: event)
        }
        self.highlightPolyline(to: nil)
        
        self.isTouching = false
        self.isDragging = false
        self.isHorizontalDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isTouching {
            
            self.isDragging = false
            self.isHorizontalDragging = false
            
            super.touchesCancelled(touches, with: event)
            return
        }
        
        if !self.isDragging || !self.isHorizontalDragging {
            super.touchesCancelled(touches, with: event)
        }
        self.highlightPolyline(to: nil)
        
        self.isTouching = false
        self.isDragging = false
        self.isHorizontalDragging = false
    }
    
    private func highlightPolyline(to currPoint: CGPoint?) {
        let prevIndex = self.currentHighlightIndex
        let currIndex = currPoint == nil ? nil : self.indexPolyline(by: currPoint!)
        if currIndex == prevIndex {
            return
        }
        
        self.dragSwitchImpactor.impactOccurred()
        
        var prevPolylineTopPoint: CGPoint? = nil
        if let prevIndex = prevIndex,
            let element = self.polylineElements.get(prevIndex) {
            
            prevPolylineTopPoint = CGPoint(
                x: self.getLayoutRtlX(element.top.x),
                y: self.getLayoutY(element.top.y) - highlightProgressDeltaY
            )
                        
            let pathEnd = self.getPolylinePath(by: element.top)
            self.animate(shape: element.shape, to: pathEnd, and: self.polylineColor(element.top.y))
        }
        if let currIndex = currIndex,
            let element = self.polylineElements.get(currIndex) {
            
            let polylineTopPoint = CGPoint(
                x: self.getLayoutRtlX(element.top.x),
                y: self.getLayoutY(element.top.y) - highlightProgressDeltaY
            )
                       
            let pathEnd = self.getPolylinePath(by: element.top)
            pathEnd.addLine(to: polylineTopPoint)
            
            self.animate(shape: element.shape, to: pathEnd, and: self.polylineTintColor)
            
            self.dragIndicator.setTitle(
                self.polylineDescriptionMapper?(element.top.y),
                for: .normal
            )
            self.dragIndicator.frame.size = self.dragIndicator.intrinsicContentSize
            self.animateIndicator(from: prevPolylineTopPoint, to: polylineTopPoint)
        } else {
            self.animateIndicator(from: prevPolylineTopPoint, to: nil)
        }
        
        self.currentHighlightIndex = currIndex
    }
    
    private func indexPolyline(by layoutPoint: CGPoint) -> Int? {
        let triggerX = (self.frame.width - 2.0 * paddingHorizontal)
        / Double(self.expectedValueCount)
        
        for (i, element) in self.polylineElements.enumerated() {
            let deltaX = self.getLayoutRtlX(element.top.x) - layoutPoint.x
            if abs(deltaX) <= triggerX {
                return i
            }
        }
        return nil
    }
    
    private func getTopX(_ layoutX: CGFloat) -> CGFloat {
        if self.isRtl {
            return (
                self.frame.width - paddingHorizontal - layoutX
            ) / (
                self.frame.width - 2 * paddingHorizontal
            )
        }
        
        return (layoutX - paddingHorizontal) / (self.frame.width - 2 * paddingHorizontal)
    }
    
    private func getTopY(_ layoutY: CGFloat) -> CGFloat {
        return (
            self.frame.height - trendPaddingBottom - layoutY
        ) / (
            self.frame.height - paddingTop - trendPaddingBottom
        )
    }
    
    private func animate(shape: CAShapeLayer, to path: UIBezierPath, and color: UIColor) {
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = path.cgPath
        
        let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
        colorAnimation.toValue = color.cgColor
        
        let shadowPathAnimation = CABasicAnimation(keyPath: "shadowPath")
        shadowPathAnimation.toValue = path.cgPath
        
        let shadowColorAnimation = CABasicAnimation(keyPath: "shadowColor")
        shadowColorAnimation.toValue = color.cgColor
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = highlightAnimationDuration
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.animations = [
            pathAnimation,
            colorAnimation,
            shadowPathAnimation,
            shadowColorAnimation,
        ]
        shape.add(animationGroup, forKey: nil)
    }
    
    private func animateIndicator(from prevLayoutAnchor: CGPoint?, to layoutAnchor: CGPoint?) {
        if prevLayoutAnchor == nil && layoutAnchor == nil {
            return
        }
        
        let centerAnimation = CABasicAnimation(keyPath: "position")
        if prevLayoutAnchor == nil {
            let endCenterPoint = self.getIndicatorCenter(by: layoutAnchor!)
            centerAnimation.fromValue = CGPoint(
                x: endCenterPoint.x,
                y: endCenterPoint.y + highlightProgressDeltaY * 2.0
            )
        }
        if layoutAnchor == nil {
            let endCenterPoint = self.getIndicatorCenter(by: prevLayoutAnchor!)
            centerAnimation.toValue = CGPoint(
                x: endCenterPoint.x,
                y: endCenterPoint.y + highlightProgressDeltaY * 2.0
            )
        } else {
            centerAnimation.toValue = self.getIndicatorCenter(by: layoutAnchor!)
        }
        
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.toValue = layoutAnchor == nil ? 0.0 : 1.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = highlightAnimationDuration
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.animations = [
            centerAnimation,
            alphaAnimation,
        ]
        self.dragIndicator.layer.add(animationGroup, forKey: nil)
    }
    
    private func getIndicatorCenter(by layoutAnchor: CGPoint) -> CGPoint {
        let size = self.dragIndicator.intrinsicContentSize
        
        let y = -0.5 * littleMargin - highlightProgressDeltaY - size.height / 2.0
        
        let bouncedMinX = paddingHorizontal + size.width / 2.0
        let bouncedMaxX = self.frame.width - paddingHorizontal - size.width / 2.0
        
        if bouncedMinX <= layoutAnchor.x && layoutAnchor.x <= bouncedMaxX {
            return CGPoint(x: layoutAnchor.x, y: y)
        }
        
        if layoutAnchor.x < bouncedMinX {
            return CGPoint(x: bouncedMinX - 0.3 * (bouncedMinX - layoutAnchor.x), y: y)
        } else {
            return CGPoint(x: bouncedMaxX + 0.3 * (layoutAnchor.x - bouncedMaxX), y: y)
        }
    }
}
