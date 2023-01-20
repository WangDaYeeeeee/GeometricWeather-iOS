//
//  Hail.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/19.
//

import SwiftUI

private let hailDayColors = [
    Color(red: 128 / 255.0, green: 197 / 255.0, blue: 255 / 255.0),
    Color(red: 185 / 255.0, green: 222 / 255.0, blue: 255 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let hailNightColors = [
    Color(red: 40 / 255.0, green: 102 / 255.0, blue: 155 / 255.0),
    Color(red: 99 / 255.0, green: 144 / 255.0, blue: 182 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]

private let hailDayBackgroundColors = [
    Color.ColorFromRGB(0x68baff),
    Color.ColorFromRGB(0x225fb6)
]
private let hailNightBckgroundColors = [
    Color.ColorFromRGB(0x1a5b92),
    Color.ColorFromRGB(0x2c4253)
]

private let hailMaxSize = 0.024
private let hailMinSize = 0.018

private let hailCount = 150

// MARK: - foreground.

struct HailForegroundView: View {
    
    let daylight: Bool
    @StateObject private var model = HailModel()
    
    let width: CGFloat
    let height: CGFloat
    
    let rotation2D: Double
    let rotation3D: Double
    
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    
    var body: some View {
        model.checkToInit(daylight: daylight)
        let canvasSize = sqrt(width * width + height * height)
        
        return Group {
            // snow flakes.
            ForEach(0 ..< model.hails.count, id: \.self) { i in
                HailLayer(
                    model: model,
                    index: i,
                    canvasSize: canvasSize
                )
            }.rotationEffect(
                Angle(degrees: rotation2D + 180.0)
            ).offset(
                x: (width - canvasSize) / 2.0,
                y: (height - canvasSize) / 2.0
            ).offset(
                x: 0.0,
                y: getDeltaY() * 0.25
            )
        }.opacity(
            Double(
                1 - self.scrollOffset / (self.headerHeight - 256.0 - 80.0)
            ).keepIn(range: 0...1) * 0.8 + 0.2
        )
    }
    
    private func getDeltaX() -> CGFloat {
        return CGFloat(
            sin(
                rotation2D / 180.0 * Double.pi
            ) * 0.3 * Double(width)
        )
    }
    
    private func getDeltaY() -> CGFloat {
        return CGFloat(
            sin(
                rotation3D / 180.0 * Double.pi
            ) * -0.3 * Double(width)
        )
    }
}

private class HailModel: ObservableObject {
    
    // init x, init y, size, target offset x, color, period.
    var hails = [(Double, Double, Double, Double, Color, Double)]()
    
    private var newInstance = true
    
    func checkToInit(daylight: Bool) {
        if !newInstance {
            return
        }
        newInstance = false
        
        // let snowflakes fly from bottom to top,
        // and then rotate them to a right angle.
        let snowColors = daylight ? hailDayColors : hailNightColors
        for i in 0 ..< hailCount {
            hails.append((
                // init x.
                Double.random(in: 0 ... 1.0),
                // init y.
                Double.random(in: 0 ... 2.0) + 1.0,
                // size.
                Double.random(
                    in: hailMinSize ... hailMaxSize
                ) * [0.6, 0.8, 1.0][i / (hailCount / 3)],
                // target offset x.
                (
                    Double.random(in: 0 ... 0.75) + 0.25
                ) * (
                    Bool.random() ? -1 : 1
                ),
                // color.
                snowColors[i / (hailCount / snowColors.count)],
                // period.
                Double.random(
                    in: 1.5 ... 3.0
                ) * pow(
                    [0.6, 0.8, 1.0][i / (hailCount / 3)],
                    1.1
                )
            ))
        }
    }
}

private struct HailLayer: View {
    
    @State private var x: Double
    @State private var y: Double
    @State private var rotation: Double
    private let animation: Animation
    
    private var initX: Double
    private var initY: Double
    
    private let size: Double
    private let targetOffsetX: Double
    
    private let color: Color
    
    // fake state. (canvas size will change with the interface orientation)
    @State private var canvasSize: Double
    
    init(
        model: HailModel,
        index: Int,
        canvasSize: Double
    ) {
        self.initX = model.hails[index].0
        self.initY = model.hails[index].1
        self.size = model.hails[index].2
        self.targetOffsetX = model.hails[index].3
        self.color = model.hails[index].4
        self.canvasSize = canvasSize
        
        self.x = initX
        self.y = initY
        self.rotation = 0
        self.animation = Animation.linear(
            duration: model.hails[index].5
        ).repeatForever(
            autoreverses: false
        )
    }
    
    var body: some View {
        Rectangle().rotation(
            Angle(degrees: rotation)
        ).fill(
            color,
            style: FillStyle()
        ).frame(
            width: canvasSize * size,
            height: canvasSize * size
        ).position(
            x: x * canvasSize,
            y: y * canvasSize
        ).onAppear {
            withAnimation(animation) {
                x = initX + targetOffsetX
                y = -size - 1
                rotation = 360.0 * 6
            }
        }
    }
}

private struct HailShape: Shape {
    
    private var x: Double
    private var y: Double
    private let size: Double
    
    init(x: Double, y: Double, size: Double) {
        self.x = x
        self.y = y
        self.size = size
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addRect(
            CGRect(
                x: x,
                y: y,
                width: rect.width,
                height: rect.height
            )
        )
        return p
    }
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            return AnimatablePair(x, y)
        }
        set {
            x = newValue.first
            y = newValue.second
        }
    }
}

// MARK: - background.

struct HailBackgroundView: View {
    
    let daylight: Bool
    
    init(daylight: Bool) {
        self.daylight = daylight
    }
    
    var body: some View {
        return LinearGradient(
            gradient: Gradient(
                colors: daylight ? hailDayBackgroundColors : hailNightBckgroundColors
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.

struct Hail_Previews: PreviewProvider {
    
    static var previews: some View {
        GeometryReader { proxy in
            HailForegroundView(
                daylight: true,
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            HailBackgroundView(daylight: true)
        ).ignoresSafeArea()
    }
}
