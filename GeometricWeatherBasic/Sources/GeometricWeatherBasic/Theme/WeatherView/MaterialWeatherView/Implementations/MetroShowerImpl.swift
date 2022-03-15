//
//  MetroShower.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/16.
//

import SwiftUI

private let startColors = [
    Color(red: 210 / 255.0, green: 247 / 255.0, blue: 255 / 255.0),
    Color(red: 208 / 255.0, green: 233 / 255.0, blue: 255 / 255.0),
    Color(red: 175 / 255.0, green: 201 / 255.0, blue: 228 / 255.0),
    Color(red: 164 / 255.0, green: 194 / 255.0, blue: 220 / 255.0),
    Color(red: 97 / 255.0, green: 171 / 255.0, blue: 220 / 255.0),
    Color(red: 74 / 255.0, green: 141 / 255.0, blue: 193 / 255.0),
    Color(red: 54 / 255.0, green: 66 / 255.0, blue: 119 / 255.0),
    Color(red: 34 / 255.0, green: 48 / 255.0, blue: 74 / 255.0),
    Color(red: 236 / 255.0, green: 234 / 255.0, blue: 213 / 255.0),
    Color(red: 240 / 255.0, green: 220 / 255.0, blue: 151 / 255.0)
]

private let backgroundColor1 = Color.ColorFromRGB(0x141b2c)
private let backgroundColor2 = Color.ColorFromRGB(0x000000)

private let shootingStartCount = 18
private let shootingStarWidthRatio = 0.0025
private let shootingStarLengthMaxRatio = 1.1 / cos(60.0 * Double.pi / 180.0)
private let shootingStarLengthMinRatio = 0.7 * shootingStarLengthMaxRatio

private let startCount = 50
private let starRadiusRatio = 0.00125

// MARK: - foreground.
struct MetroShowerForegroundView: View {
    
    @StateObject private var model = MetroShowerModel()
    
    let width: CGFloat
    let height: CGFloat
    
    let rotation2D: Double
    let rotation3D: Double
    
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    
    var body: some View {
        let canvasSize = sqrt(width * width + height * height)
        
        return Group {
            // stars.
            ForEach(0 ..< model.stars.count) { i in
                StarLayer(
                    model: model,
                    index: i,
                    canvasSize: canvasSize
                )
            }.offset(
                x: (width - canvasSize) / 2.0,
                y: (height - canvasSize) / 2.0
            ).offset(
                x: getDeltaX() * 0.25,
                y: getDeltaY() * 0.25
            )
            
            // shooting stars.
            ForEach(0 ..< model.shootingStars.count) { i in
                ShootingStarLayer(
                    model: model,
                    index: i,
                    canvasSize: canvasSize
                )
            }.frame(
                width: canvasSize,
                height: canvasSize
            ).rotationEffect(
                Angle(degrees: rotation2D - 120.0)
            ).offset(
                x: (width - canvasSize) / 2.0,
                y: (height - canvasSize) / 2.0
            ).offset(
                x: 0.0,
                y: getDeltaY()
            ).opacity(
                Double(
                    1 - self.scrollOffset / (self.headerHeight - 256.0 - 80.0)
                ).keepIn(range: 0...1)
            )
        }
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

private class MetroShowerModel: ObservableObject {
    
    // init x, init y, width, length, color, period.
    var shootingStars: Array<(Double, Double, Double, Double, Color, Double)>
    // cx, cy, radius, color, shining duration.
    var stars: Array<(Double, Double, Double, Color, Double)>
    
    init() {
        // shooting stars in foreground.
        // let shooting stars fly from bottom to top,
        // and then rotate them to a right angle.
        shootingStars = [
            // init x, init y, width, length, color, period.
            (Double, Double, Double, Double, Color, Double)
        ]()
        for _ in 0 ..< shootingStartCount {
            let len = Double.random(
                in: shootingStarLengthMinRatio ... shootingStarLengthMaxRatio
            )
            shootingStars.append((
                // init x.
                Double.random(in: 0 ... 1.0),
                // init y.
                Double.random(in: 0 ... 1.0) + 1.0,
                // width.
                shootingStarWidthRatio * Double.random(
                    in: 0.25 ... 1.5
                ),
                // length.
                len,
                // color.
                startColors[Int.random(in: 0 ..< startColors.count)],
                // period.
                2.0 + Double.random(in: 0.0 ... 3.0)
            ))
        }
        
        // stars in background.
        stars = [
           // cx, cy, radius, color, shining duration.
           (Double, Double, Double, Color, Double)
        ]()
        for _ in 0 ..< startCount {
            stars.append((
                // cx.
                Double.random(in: 0 ... 1.0),
                // cy.
                Double.random(in: 0 ... 1.0),
                // radius.
                starRadiusRatio * Double.random(
                    in: 0.5 ... 1.5
                ),
                // color.
                startColors[
                    Int.random(in: 0 ..< startColors.count)
                ],
                // duration.
                (2.5 + Double.random(in: 0.0 ..< 2.5)) / 2.0
            ))
        }
    }
}

private struct ShootingStarLayer: View {
    
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
        model: MetroShowerModel,
        index: Int,
        canvasSize: Double
    ) {
        self.initX = model.shootingStars[index].0
        self.initY = model.shootingStars[index].1
        self.width = model.shootingStars[index].2
        self.length = model.shootingStars[index].3
        self.color = model.shootingStars[index].4
        self.canvasSize = canvasSize
        
        self.y = initY
        self.animation = Animation.linear(
            duration: model.shootingStars[index].5
        ).repeatForever(
            autoreverses: false
        )
    }
    
    var body: some View {
        ShootingStarShape(
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

private struct ShootingStarShape: Shape {
    
    private let x: Double
    private var y: Double
    private let length: Double
    
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
    
    var animatableData: Double {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
}

private struct StarLayer: View {
    
    @State private var opacity = 0.0
    private let animation: Animation
    
    let cx: Double
    let cy: Double
    let radius: Double
    
    let color: Color
    
    // fake state. (canvas size will change with the interface orientation)
    @State private var canvasSize: Double
    
    init(
        model: MetroShowerModel,
        index: Int,
        canvasSize: Double
    ) {
        self.cx = model.stars[index].0
        self.cy = model.stars[index].1
        self.radius = model.stars[index].2
        self.color = model.stars[index].3
        self.canvasSize = canvasSize
        
        self.animation = Animation.easeInOut(
            duration: model.stars[index].4
        ).repeatForever(
            autoreverses: true
        )
    }
    
    var body: some View {
        StarShape(
            cx: canvasSize * cx,
            cy: canvasSize * cy,
            radius: canvasSize * radius
        ).fill(
            color.opacity(opacity)
        ).onAppear {
            withAnimation(animation) {
                opacity = 1.0
            }
        }
    }
}

private struct StarShape: Shape {
    
    private let cx: Double
    private let cy: Double
    private let radius: Double
    
    init(
        cx: Double,
        cy: Double,
        radius: Double
    ) {
        self.cx = cx
        self.cy = cy
        self.radius = radius
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: cx, y: cy),
            radius: radius,
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 360.0),
            clockwise: true
        )
        return p
    }
}

// MARK: - background.
struct MetroShowerBackgroundView: View {
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                backgroundColor1,
                backgroundColor2
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.
struct MetroShower_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            MetroShowerForegroundView(
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            MetroShowerBackgroundView()
        ).ignoresSafeArea()
    }
}
