//
//  Snow.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/19.
//

import SwiftUI

private let snowDayColors = [
    Color(red: 128 / 255.0, green: 197 / 255.0, blue: 255 / 255.0),
    Color(red: 185 / 255.0, green: 222 / 255.0, blue: 255 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let snowNightColors = [
    Color(red: 40 / 255.0, green: 102 / 255.0, blue: 155 / 255.0),
    Color(red: 99 / 255.0, green: 144 / 255.0, blue: 182 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]

private let snowDayBackgroundColors = [
    Color.ColorFromRGB(0x68baff),
    Color.ColorFromRGB(0x225fb6)
]
private let snowNightBckgroundColors = [
    Color.ColorFromRGB(0x1a5b92),
    Color.ColorFromRGB(0x2c4253)
]

private let snowflakeMaxRaidus = 0.012
private let snowflakeMinRadius = 0.005

private let snowflakeCount = 180

// MARK: - foreground.

struct SnowForegroundView: View {
    
    private let daylight: Bool
    @StateObject private var model = SnowModel()
    
    private let width: CGFloat
    private let height: CGFloat
    
    private let rotation2D: Double
    private let rotation3D: Double
    
    private let scrollOffset: CGFloat
    private let headerHeight: CGFloat
    
    init(
        daylight: Bool,
        width: CGFloat,
        height: CGFloat,
        rotation2D: Double,
        rotation3D: Double,
        scrollOffset: CGFloat,
        headerHeight: CGFloat
    ) {
        self.daylight = daylight
        self.width = width
        self.height = height
        self.rotation2D = rotation2D
        self.rotation3D = rotation3D
        self.scrollOffset = scrollOffset
        self.headerHeight = headerHeight
    }
    
    var body: some View {
        model.checkToInit(daylight: daylight)
        let canvasSize = sqrt(width * width + height * height)
        
        return ForEach(0 ..< model.snowflakes.count) { i in
            SnowflakeLayer(
                model: model,
                index: i,
                canvasSize: canvasSize
            )
        }.frame(
            width: canvasSize,
            height: canvasSize
        ).rotationEffect(
            Angle(degrees: rotation2D + 180.0 + 8.0)
        ).offset(
            x: (width - canvasSize) / 2.0,
            y: (height - canvasSize) / 2.0
        ).offset(
            x: 0.0,
            y: getDeltaY() * 0.25
        ).opacity(
            Double(
                1 - 4 * self.scrollOffset / self.headerHeight
            ).keepIn(range: 0...1)
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

private class SnowModel: ObservableObject {
    
    // init x, init y, radius, target offset x, color, period.
    var snowflakes = [(Double, Double, Double, Double, Color, Double)]()
    
    private var newInstance = true
    
    func checkToInit(daylight: Bool) {
        if !newInstance {
            return
        }
        newInstance = false
        
        // let snowflakes fly from bottom to top,
        // and then rotate them to a right angle.
        let snowColors = daylight ? snowDayColors : snowNightColors
        for i in 0 ..< snowflakeCount {
            snowflakes.append((
                // init x.
                Double.random(in: 0 ... 1.0),
                // init y.
                Double.random(in: 0 ... 2.0) + 1.0,
                // radius.
                Double.random(
                    in: snowflakeMinRadius ... snowflakeMaxRaidus
                ) * [0.6, 0.8, 1.0][i / (snowflakeCount / 3)],
                // target offset x.
                (
                    Double.random(in: 0 ... 1.25) + 0.25
                ) * (
                    Bool.random() ? -1 : 1
                ),
                // color.
                snowColors[i / (snowflakeCount / snowColors.count)],
                // period.
                Double.random(
                    in: 2.5 ... 3.5
                ) * pow(
                    [0.6, 0.8, 1.0][i / (snowflakeCount / 3)],
                    1.1
                )
            ))
        }
    }
}

private struct SnowflakeLayer: View {
    
    @State private var x: Double
    @State private var y: Double
    private let animation: Animation
    
    private var initX: Double
    private var initY: Double
    
    private let radius: Double
    private let targetOffsetX: Double
    
    private let color: Color
    
    // fake state. (canvas size will change with the interface orientation)
    @State private var canvasSize: Double
    
    init(
        model: SnowModel,
        index: Int,
        canvasSize: Double
    ) {
        self.initX = model.snowflakes[index].0
        self.initY = model.snowflakes[index].1
        self.radius = model.snowflakes[index].2
        self.targetOffsetX = model.snowflakes[index].3
        self.color = model.snowflakes[index].4
        self.canvasSize = canvasSize
        
        self.x = initX
        self.y = initY
        self.animation = Animation.linear(
            duration: model.snowflakes[index].5
        ).repeatForever(
            autoreverses: false
        )
    }
    
    var body: some View {
        SnowflakeShape(
            x: canvasSize * x,
            y: canvasSize * y,
            radius: canvasSize * radius
        ).fill(
            color,
            style: FillStyle()
        ).onAppear {
            withAnimation(animation) {
                x = initX + targetOffsetX
                y = -radius - 1
            }
        }
    }
}

private struct SnowflakeShape: Shape {
    
    private var x: Double
    private var y: Double
    private let radius: Double
    
    init(x: Double, y: Double, radius: Double) {
        self.x = x
        self.y = y
        self.radius = radius
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: x, y: y),
            radius: CGFloat(radius),
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 360.0),
            clockwise: true
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

struct SnowBackgroundView: View {
    
    let daylight: Bool
    
    init(daylight: Bool) {
        self.daylight = daylight
    }
    
    var body: some View {
        return LinearGradient(
            gradient: Gradient(
                colors: daylight ? snowDayBackgroundColors : snowNightBckgroundColors
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.

struct Snow_Previews: PreviewProvider {
    
    static var previews: some View {
        GeometryReader { proxy in
            SnowForegroundView(
                daylight: true,
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            SnowBackgroundView(daylight: true)
        ).ignoresSafeArea()
    }
}
