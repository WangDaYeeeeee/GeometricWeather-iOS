//
//  Rain.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/19.
//

import SwiftUI

enum RainType {
    case rainy
    case thunderstrom
    case sleet
}
enum RainLevel: Double {
    case light = 0.8
    case middle = 1.0
    case heavy = 1.2
}

private let rainyDayColors = [
    Color(red: 223 / 255.0, green: 179 / 255.0, blue: 114 / 255.0),
    Color(red: 152 / 255.0, green: 175 / 255.0, blue: 222 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let rainyNightColors = [
    Color(red: 182 / 255.0, green: 142 / 255.0, blue: 82 / 255.0),
    Color(red: 88 / 255.0, green: 92 / 255.0, blue: 113 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let sleetDayColors = [
    Color(red: 128 / 255.0, green: 197 / 255.0, blue: 255 / 255.0),
    Color(red: 185 / 255.0, green: 222 / 255.0, blue: 255 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let sleetNightColors = [
    Color(red: 40 / 255.0, green: 102 / 255.0, blue: 155 / 255.0),
    Color(red: 99 / 255.0, green: 144 / 255.0, blue: 182 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let thunderstormDayColors = [
    Color(red: 182 / 255.0, green: 142 / 255.0, blue: 82 / 255.0),
    Color.ColorFromRGB(0x6C5592),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]
private let thunderstormNightColors = [
    Color(red: 182 / 255.0, green: 142 / 255.0, blue: 82 / 255.0),
    Color(red: 88 / 255.0, green: 92 / 255.0, blue: 113 / 255.0),
    Color(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0)
]

private let thunderDayColor = Color.ColorFromRGB(
    0xE5D5EB
).opacity(0.8)
private let thunderNightColor = Color(
    red: 81 / 255.0,
    green: 67 / 455.0,
    blue: 168 / 255.0,
    opacity: 0.66
)

private let rainyDayBackgroundColors = [
    Color.ColorFromRGB(0x4097e7),
    Color.ColorFromRGB(0x3a4d80)
]
private let rainyNightBckgroundColors = [
    Color.ColorFromRGB(0x264e8f),
    Color.ColorFromRGB(0x252f60)
]
private let sleetDayBackgroundColors = [
    Color.ColorFromRGB(0x68baff),
    Color.ColorFromRGB(0x0071ff)
]
private let sleetNightBackgroundColors = [
    Color.ColorFromRGB(0x1a5b92),
    Color.ColorFromRGB(0x263f56)
]
private let thunderstromDayBackgroundColors = [
    Color.ColorFromRGB(0xB296BD),
    Color.ColorFromRGB(0x50367F)
]
private let thunderstromNightBackgroundColors = [
    Color.ColorFromRGB(0x2b1d45),
    Color.ColorFromRGB(0x06040a)
]

private let raindropMaxWidth = 0.006
private let raindropMinWidth = 0.003
private let raindropMaxLength = raindropMaxWidth * 10
private let raindropMinLength = raindropMinWidth * 6

private let rainyRaindropCount = 150

// MARK: - foreground.

struct RainForegroundView: View {
    
    let type: RainType
    let daylight: Bool
    let level: RainLevel
    @StateObject private var model = RainModel()
    
    let width: CGFloat
    let height: CGFloat
    
    let rotation2D: Double
    let rotation3D: Double
    
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    
    var body: some View {
        model.checkToInit(type: type, daylight: daylight, level: level)
        let canvasSize = sqrt(width * width + height * height)
        
        return GeometryReader { proxy in
            // thunder.
            if type == .thunderstrom {
                ThunderLayer(
                    daylight: self.daylight
                ).frame(
                    width: proxy.size.width,
                    height: proxy.size.height
                ).offset(
                    x: (width - proxy.size.width) / 2.0,
                    y: (height - proxy.size.height) / 2.0
                ).opacity(
                    Double(
                        1 - self.scrollOffset / (self.headerHeight - 256.0 - 80.0)
                    ).keepIn(range: 0...1) * 0.8 + 0.2
                )
            }
            
            // raindrops.
            ForEach(0 ..< model.raindrops.count) { i in
                RaindropLayer(
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
                    1 - self.scrollOffset / (self.headerHeight - 256.0 - 80.0)
                ).keepIn(range: 0...1) * 0.8 + 0.2
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

private class RainModel: ObservableObject {
    
    // init x, init y, width, length, color, period.
    var raindrops = [(Double, Double, Double, Double, Color, Double)]()
    
    private var newInstance = true
    
    func checkToInit(type: RainType, daylight: Bool, level: RainLevel) {
        if !newInstance {
            return
        }
        newInstance = false
        
        // let raindrop fly from bottom to top,
        // and then rotate them to a right angle.
        let raindropCount = Int(Double(rainyRaindropCount) * level.rawValue)
        var raindropColors: Array<Color>
        switch type {
        case .rainy:
            raindropColors = daylight ? rainyDayColors : rainyNightColors
            
        case .thunderstrom:
            raindropColors = daylight
            ? thunderstormDayColors
            : thunderstormNightColors
            
        case .sleet:
            raindropColors = daylight ? sleetDayColors : sleetNightColors
        }
        
        for i in 0 ..< raindropCount {
            raindrops.append((
                // init x.
                Double.random(in: 0 ... 1.0),
                // init y.
                Double.random(in: 0 ... 3.0) + 1.0,
                // width.
                Double.random(in: raindropMinWidth ... raindropMaxWidth),
                // length.
                Double.random(in: raindropMinLength ... raindropMaxLength),
                // color.
                raindropColors[i / (raindropCount / raindropColors.count)],
                // period.
                Double.random(
                    in: 1.75 ... 2.75
                ) * pow(
                    [0.6, 0.8, 1.0][i / (raindropCount / 3)],
                    1.1
                )
            ))
        }
    }
}

private struct RaindropLayer: View {
    
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
        model: RainModel,
        index: Int,
        canvasSize: Double
    ) {
        self.initX = model.raindrops[index].0
        self.initY = model.raindrops[index].1
        self.width = model.raindrops[index].2
        self.length = model.raindrops[index].3
        self.color = model.raindrops[index].4
        self.canvasSize = canvasSize
        
        self.y = initY
        self.animation = Animation.linear(
            duration: model.raindrops[index].5
        ).repeatForever(
            autoreverses: false
        )
    }
    
    var body: some View {
        RaindropShape(
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

private struct RaindropShape: Shape {
    
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

private struct ThunderLayer: View {
    
    @State private var opacity = 0.0
    let daylight: Bool
    
    private let animation = Animation.linear(
        duration: 3.0
    )
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                self.daylight ? thunderDayColor : thunderNightColor,
                .clear
            ]),
            startPoint: .top,
            endPoint: .bottom
        ).opacity(
            opacity
        ).onAppear {
            registerThunderShinning()
        }
    }
    
    private func registerThunderShinning() {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double.random(in: 7.5 ... 12.5)
        ) {
            opacity = 1.0
            withAnimation(animation) {
                opacity = 0.0
            }
            
            registerThunderShinning()
        }
    }
}

// MARK: - background.

struct RainBackgroundView: View {
    
    let type: RainType
    let daylight: Bool
    
    var body: some View {
        switch type {
        case .rainy:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? rainyDayBackgroundColors
                    : rainyNightBckgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        case .sleet:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? sleetDayBackgroundColors
                    : sleetNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        case .thunderstrom:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? thunderstromDayBackgroundColors
                    : thunderstromNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

struct RainDayWidgetBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.ColorFromRGB(0x4bbcff),
                Color.ColorFromRGB(0x3a4d80)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.

struct Rain_Previews: PreviewProvider {
    
    static let type = RainType.thunderstrom
    static let daylight = true
    
    static var previews: some View {
        GeometryReader { proxy in
            RainForegroundView(
                type: type,
                daylight: daylight,
                level: .heavy,
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            RainBackgroundView(type: type, daylight: daylight)
        ).ignoresSafeArea()
    }
}
