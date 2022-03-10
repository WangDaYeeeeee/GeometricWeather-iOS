//
//  Wind.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/19.
//

import SwiftUI

private let windColors = [
    Color(red: 240 / 255.0, green: 200 / 255.0, blue: 148 / 255.0),
    Color(red: 237 / 255.0, green: 178 / 255.0, blue: 100 / 255.0),
    Color(red: 209 / 255.0, green: 142 / 255.0, blue: 54 / 255.0)
]

private let backgroundColors = [
    Color.ColorFromRGB(0xe99e3c),
    Color.ColorFromRGB(0xff8300)
]

private let windMaxWidth = 0.006
private let windMinWidth = 0.003
private let windMaxLength = windMaxWidth * 10
private let windMinLength = windMinWidth * 6

private let windCount = 240

// MARK: - foreground.

struct WindForegroundView: View {
    
    @StateObject private var model = WindModel()
    
    private let width: CGFloat
    private let height: CGFloat
    
    private let rotation2D: Double
    private let rotation3D: Double
    
    private let scrollOffset: CGFloat
    private let headerHeight: CGFloat
    
    init(
        width: CGFloat,
        height: CGFloat,
        rotation2D: Double,
        rotation3D: Double,
        scrollOffset: CGFloat,
        headerHeight: CGFloat
    ) {
        self.width = width
        self.height = height
        self.rotation2D = rotation2D
        self.rotation3D = rotation3D
        self.scrollOffset = scrollOffset
        self.headerHeight = headerHeight
    }
    
    var body: some View {
        model.checkToInit()
        let canvasSize = sqrt(width * width + height * height)
        
        return ForEach(0 ..< model.winds.count) { i in
            WindLayer(
                model: model,
                index: i,
                canvasSize: canvasSize
            )
        }.frame(
            width: canvasSize,
            height: canvasSize
        ).rotationEffect(
            Angle(degrees: rotation2D + 90.0 - 8.0)
        ).offset(
            x: (width - canvasSize) / 2.0,
            y: (height - canvasSize) / 2.0
        ).offset(
            x: 0.0,
            y: getDeltaY() * 0.25
        ).opacity(
            Double(
                1 - self.scrollOffset / (self.headerHeight - 256.0 - 80.0)
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

private class WindModel: ObservableObject {
    
    // init x, init y, width, length, color, period.
    var winds = [(Double, Double, Double, Double, Color, Double)]()
    
    private var newInstance = true
    
    func checkToInit() {
        if !newInstance {
            return
        }
        newInstance = false
        
        for i in 0 ..< windCount {
            winds.append((
                // init x.
                Double.random(in: 0 ... 1.0),
                // init y.
                Double.random(in: 0 ... 3.0) + 1.0,
                // width.
                Double.random(in: windMinWidth ... windMaxWidth),
                // length.
                Double.random(in: windMinLength ... windMaxLength),
                // color.
                windColors[i / (windCount / windColors.count)],
                // period.
                Double.random(
                    in: 0.5 ... 1.5
                ) * [0.6, 0.8, 1.0][i / (windCount / 3)]
            ))
        }
    }
}

private struct WindLayer: View {
    
    @State private var y: Double
    private let animation: Animation
    
    private var initX: Double
    private var initY: Double
    
    private let width: Double
    private let length: Double
    
    private let color: Color
    
    // fake state. (canvas size will change with the interface orientation)
    @State private var canvasSize: Double
    
    init(
        model: WindModel,
        index: Int,
        canvasSize: Double
    ) {
        self.initX = model.winds[index].0
        self.initY = model.winds[index].1
        self.width = model.winds[index].2
        self.length = model.winds[index].3
        self.color = model.winds[index].4
        self.canvasSize = canvasSize
        
        self.y = initY
        self.animation = Animation.linear(
            duration: model.winds[index].5
        ).repeatForever(
            autoreverses: false
        )
    }
    
    var body: some View {
        WindShape(
            x: canvasSize * initX,
            y: canvasSize * y,
            length: canvasSize * length
        ).stroke(
            color,
            style: StrokeStyle(lineWidth: canvasSize * width, lineCap: .round)
        ).onAppear {
            withAnimation(animation) {
                y = -length - 1
            }
        }
    }
}

private struct WindShape: Shape {
    
    private var x: Double
    private var y: Double
    private var length: Double
    
    init(x: Double, y: Double, length: Double) {
        self.x = x
        self.y = y
        self.length = length
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: x, y: y))
        p.addLine(to: CGPoint(x: x, y: y + length))
        return p
    }
    
    var animatableData: AnimatablePair<
        AnimatablePair<Double, Double>, Double
    > {
        get {
            return AnimatablePair(
                AnimatablePair(x, y),
                length
            )
        }
        set {
            x = newValue.first.first
            y = newValue.first.second
            length = newValue.second
        }
    }
}

// MARK: - background.

struct WindBackgroundView: View {
    
    var body: some View {
        return LinearGradient(
            gradient: Gradient(colors: backgroundColors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.

struct Wind_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            WindForegroundView(
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            WindBackgroundView()
        ).ignoresSafeArea()
    }
}
