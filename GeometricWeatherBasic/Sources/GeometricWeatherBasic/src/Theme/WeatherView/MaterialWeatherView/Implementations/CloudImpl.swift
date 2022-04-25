//
//  Cloud.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/18.
//

import SwiftUI

enum CloudType {
    case partlyCloudy
    case cloudy
    case thunder
    case fog
    case haze
}

private let partlyCloudyColors = [
    [
        Color(
            red: 203 / 255.0,
            green: 245 / 255.0,
            blue: 1.0,
            opacity: 0.4
        ),
        Color(
            red: 203 / 255.0,
            green: 245 / 255.0,
            blue: 1.0,
            opacity: 0.1
        )
    ], [
        Color(
            red: 151 / 255.0,
            green: 168 / 255.0,
            blue: 202 / 255.0,
            opacity: 0.4
        ),
        Color(
            red: 151 / 255.0,
            green: 168 / 255.0,
            blue: 202 / 255.0,
            opacity: 0.1
        )
    ]
]

private let cloudyThunderColors = [
    [// cloudy day.
        Color(
            red: 160 / 255.0,
            green: 179 / 255.0,
            blue: 191 / 255.0,
            opacity: 0.3
        ),
        Color(
            red: 160 / 255.0,
            green: 179 / 255.0,
            blue: 191 / 255.0,
            opacity: 0.3
        )
    ], [ // cloudy night.
        Color(
            red: 95 / 255.0,
            green: 104 / 255.0,
            blue: 108 / 255.0,
            opacity: 0.3
        ),
        Color(
            red: 95 / 255.0,
            green: 104 / 255.0,
            blue: 108 / 255.0,
            opacity: 0.3
        )
    ], [ // thunder day.
        Color.ColorFromRGB(0xBCADC1).opacity(0.2),
        Color.ColorFromRGB(0xBCADC1).opacity(0.3)
    ], [ // thunder night.
        Color(
            red: 43 / 255.0,
            green: 30 / 255.0,
            blue: 66 / 255.0,
            opacity: 0.8
        ),
        Color(
            red: 53 / 255.0,
            green: 38 / 255.0,
            blue: 78 / 255.0,
            opacity: 0.8
        )
    ]
]

private let fogHazeColors = [
    [ // fog day.
        Color.ColorFromRGB(0x717DA0).opacity(0.1),
        Color.ColorFromRGB(0x717DA0).opacity(0.1),
        Color.ColorFromRGB(0x717DA0).opacity(0.1),
    ], [ // fog night.
        Color(
            red: 85 / 255.0,
            green: 99 / 255.0,
            blue: 110 / 255.0,
            opacity: 0.4
        ),
        Color(
            red: 91 / 255.0,
            green: 104 / 255.0,
            blue: 114 / 255.0,
            opacity: 0.6
        ),
        Color(
            red: 99 / 255.0,
            green: 113 / 255.0,
            blue: 123 / 255.0,
            opacity: 0.4
        )
    ], [ // haze day.
        Color.ColorFromRGB(0xAC9D82).opacity(0.3),
        Color.ColorFromRGB(0xAC9D82).opacity(0.3),
        Color.ColorFromRGB(0xAC9D82).opacity(0.3)
    ], [ // haze night.
        Color(
            red: 179 / 255.0,
            green: 158 / 255.0,
            blue: 132 / 255.0,
            opacity: 0.3
        ),
        Color(
            red: 179 / 255.0,
            green: 158 / 255.0,
            blue: 132 / 255.0,
            opacity: 0.3
        ),
        Color(
            red: 179 / 255.0,
            green: 158 / 255.0,
            blue: 132 / 255.0,
            opacity: 0.3
        )
    ]
]

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

private let thunderDayColor = Color.ColorFromRGB(
    0xE5D5EB
).opacity(0.8)
private let thunderNightColor = Color(
    red: 81 / 255.0,
    green: 67 / 455.0,
    blue: 168 / 255.0,
    opacity: 0.8
)

private let partlyCloudyDayBackgroundColors = [
    Color.ColorFromRGB(0x00a5d9),
    Color.ColorFromRGB(0x1762ac)
]
private let partlyCloudyNightBackgroundColors = [
    Color.ColorFromRGB(0x222d43),
    Color.ColorFromRGB(0x000000)
]
private let cloudyDayBackgroundColors = [
    Color.ColorFromRGB(0x9DAFC1),
    Color.ColorFromRGB(0x2d5879)
]
private let cloudyNightBackgroundColors = [
    Color.ColorFromRGB(0x263238),
    Color.ColorFromRGB(0x080d10)
]
private let thunderDayBackgroundColors = [
    Color.ColorFromRGB(0xB296BD),
    Color.ColorFromRGB(0x50367F)
]
private let thunderNightBackgroundColors = [
    Color.ColorFromRGB(0x231739),
    Color.ColorFromRGB(0x06040a)
]
private let fogDayBackgroundColors = [
    Color.ColorFromRGB(0xD7DDE8),
    Color.ColorFromRGB(0x757F9A)
]
private let fogNightBackgroundColors = [
    Color.ColorFromRGB(0x4f5d68),
    Color.ColorFromRGB(0x1c232d)
]
private let hazeDayBackgroundColors = [
    Color.ColorFromRGB(0xE1C899),
    Color.ColorFromRGB(0x8CA2A5)
]
private let hazeNightBackgroundColors = [
    Color.ColorFromRGB(0x6c5c49),
    Color.ColorFromRGB(0x434343)
]

private let topPadding = 80.0

private let startCount = 50
private let starRadiusRatio = 0.00125

// MARK: - foreground.

struct CloudForegroundView: View {
    
    let type: CloudType
    let daylight: Bool
    @StateObject private var model = CloudModel()
    
    let width: CGFloat
    let height: CGFloat
    
    let rotation2D: Double
    let rotation3D: Double
    
    let paddingTop: Double
    
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    
    var body: some View {
        model.checkToInit(type: type, daylight: daylight)
        let canvasSize = sqrt(width * width + height * height)
                
        return GeometryReader { proxy in
            // stars.
            StarLayer(
                model: self.model,
                canvasSize: canvasSize
            ).offset(
                x: (width - canvasSize) / 2.0,
                y: (height - canvasSize) / 2.0
            ).offset(
                x: getDeltaX() * 0.25,
                y: getDeltaY() * 0.25
            )
            
            // cloud and thunder.
            CloudAndThunderLayer(
                type: self.type,
                daylight: self.daylight,
                model: self.model,
                proxy: proxy,
                canvasSize: canvasSize,
                width: self.width,
                height: self.height,
                rotation2D: self.rotation2D,
                rotation3D: self.rotation3D
            ).opacity(
                Double(
                    1 - self.scrollOffset / (self.headerHeight - 256.0 - 80.0)
                ).keepIn(range: 0...1) * 0.5 + 0.5
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

private struct StarLayer: View {
    
    @ObservedObject var model: CloudModel
    let canvasSize: CGFloat
    
    var body: some View {
        ForEach(0 ..< model.stars.count) { i in
            SingleStarLayer(
                model: model,
                index: i,
                canvasSize: canvasSize
            )
        }
    }
}

private struct CloudAndThunderLayer: View {
    
    let type: CloudType
    let daylight: Bool
    
    @ObservedObject var model: CloudModel
    let proxy: GeometryProxy
    
    let canvasSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    let rotation2D: Double
    let rotation3D: Double
    
    var body: some View {
        ForEach(0 ..< model.clouds.count) { i in
            CloudLayer(
                model: model,
                index: i,
                width: width,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            ).offset(
                x: 0.0,
                y: topPadding
            )
            
            // thunder.
            if i == 2 && type == .thunder {
                ThunderLayer(
                    daylight: self.daylight
                ).frame(
                    width: proxy.size.width,
                    height: proxy.size.height
                ).offset(
                    x: (width - proxy.size.width) / 2.0,
                    y: (height - proxy.size.height) / 2.0
                )
            }
        }
    }
}

// MARK: - model.

private class CloudModel: ObservableObject {
    
    var clouds = [
        // cx, cy, init radius, scale ratio, offset factor, color, duration.
        (Double, Double, Double, Double, Double, Color, Double)
    ]()
    var stars = [
        // cx, cy, radius, color, shining duration.
        (Double, Double, Double, Color, Double)
    ]()
    
    private var newInstance = true
    
    func checkToInit(type: CloudType, daylight: Bool) {
        if !newInstance {
            return
        }
        newInstance = false
        
        // clouds
        if type == .partlyCloudy {
            let colorIndex = daylight ? 0 : 1
            
            clouds.append((
                0.1529, // cx.
                0.1529 * 0.5568 + 0.050, // cy.
                0.2649, // init radius.
                1.2, // scale ratio.
                Double.random(in: 1.5 ... 1.8), // offset factor.
                partlyCloudyColors[colorIndex][0], // color.
                7.0 // duration.
            ))
            clouds.append((
                0.4793, // cx.
                0.4793 * 0.2185 + 0.050, // cy.
                0.2426, // init radius.
                1.2, // scale ratio.
                Double.random(in: 1.5 ... 1.8), // offset factor.
                partlyCloudyColors[colorIndex][0], // color.
                8.5 // duration.
            ))
            clouds.append((
                0.8531, // cx.
                0.8531 * 0.1286 + 0.050, // cy.
                0.2970, // init radius.
                1.2, // scale ratio.
                Double.random(in: 1.5 ... 1.8), // offset factor.
                partlyCloudyColors[colorIndex][0], // color.
                7.05 // duration.
            ))
            clouds.append((
                0.0551, // cx.
                0.0551 * 2.8600 + 0.050, // cy.
                0.4125, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.3 ... 1.5), // offset factor.
                partlyCloudyColors[colorIndex][1], // color.
                9.5 // duration.
            ))
            clouds.append((
                0.4928, // cx.
                0.4928 * 0.3897 + 0.050, // cy.
                0.3521, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.3 ... 1.5), // offset factor.
                partlyCloudyColors[colorIndex][1], // color.
                10.5 // duration.
            ))
            clouds.append((
                1.0499, // cx.
                1.0499 * 0.1875 + 0.050, // cy.
                0.4186, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.3 ... 1.5), // offset factor.
                partlyCloudyColors[colorIndex][1], // color.
                9.0 // duration.
            ))
        } else if type == .cloudy
                    || type == .thunder {
            let colorIndex = (type == .cloudy ? 0 : 2) + (daylight ? 0 : 1)
            
            clouds.append((
                1.0699, // cx.
                1.1900 * 0.2286 + 0.11, // cy.
                0.4694 * 0.9, // init radius.
                1.10, // scale ratio.
                Double.random(in: 1.3 ... 1.8), // offset factor.
                cloudyThunderColors[colorIndex][0], // color.
                9.0 // duration.
            ))
            clouds.append((
                0.4866, // cx.
                0.4866 * 0.6064 + 0.085, // cy.
                0.3946 * 0.9, // init radius.
                1.10, // scale ratio.
                Double.random(in: 1.3 ... 1.8), // offset factor.
                cloudyThunderColors[colorIndex][0], // color.
                10.5 // duration.
            ))
            clouds.append((
                0.0351, // cx.
                0.1701 * 1.4327 + 0.11, // cy.
                0.4627 * 0.9, // init radius.
                1.10, // scale ratio.
                Double.random(in: 1.3 ... 1.8), // offset factor.
                cloudyThunderColors[colorIndex][0], // color.
                9.0 // duration.
            ))
            clouds.append((
                0.8831, // cx.
                1.0270 * 0.1671 + 0.07, // cy.
                0.3238 * 0.9, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.6 ... 2), // offset factor.
                cloudyThunderColors[colorIndex][1], // color.
                7.0 // duration.
            ))
            clouds.append((
                0.4663, // cx.
                0.4663 * 0.3520 + 0.050, // cy.
                0.2906 * 0.9, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.6 ... 2), // offset factor.
                cloudyThunderColors[colorIndex][1], // color.
                8.5 // duration.
            ))
            clouds.append((
                0.1229, // cx.
                0.0234 * 5.7648 + 0.07, // cy.
                0.2972 * 0.9, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.6 ... 2), // offset factor.
                cloudyThunderColors[colorIndex][1], // color.
                7.0 // duration.
            ))
        } else {
            let colorIndex = (type == .fog ? 0 : 2) + (daylight ? 0 : 1)
            
            clouds.append((
                1.0699, // cx.
                1.1900 * 0.2286 + 0.11, // cy.
                0.4694 * 0.9, // init radius.
                1.10, // scale ratio.
                Double.random(in: 1.3 ... 1.8), // offset factor.
                fogHazeColors[colorIndex][0], // color.
                9.0 // duration.
            ))
            clouds.append((
                0.4866, // cx.
                0.4866 * 0.6064 + 0.085, // cy.
                0.3946 * 0.9, // init radius.
                1.10, // scale ratio.
                Double.random(in: 1.3 ... 1.8), // offset factor.
                fogHazeColors[colorIndex][0], // color.
                10.5 // duration.
            ))
            clouds.append((
                0.0351, // cx.
                0.1701 * 1.4327 + 0.11, // cy.
                0.4627 * 0.9, // init radius.
                1.10, // scale ratio.
                Double.random(in: 1.3 ... 1.8), // offset factor.
                fogHazeColors[colorIndex][0], // color.
                9.0 // duration.
            ))
            clouds.append((
                0.8831, // cx.
                1.0270 * 0.1671 + 0.07, // cy.
                0.3238 * 0.9, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.6 ... 2), // offset factor.
                fogHazeColors[colorIndex][1], // color.
                7.0 // duration.
            ))
            clouds.append((
                0.4663, // cx.
                0.4663 * 0.3520 + 0.050, // cy.
                0.2906 * 0.9, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.6 ... 2), // offset factor.
                fogHazeColors[colorIndex][1], // color.
                8.5 // duration.
            ))
            clouds.append((
                0.1229, // cx.
                0.0234 * 5.7648 + 0.07, // cy.
                0.2972 * 0.9, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.6 ... 2), // offset factor.
                fogHazeColors[colorIndex][1], // color.
                7.0 // duration.
            ))
            clouds.append((
                0.9250, // cx.
                0.9250 * 0.0249 + 0.1500, // cy.
                0.3166, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.8 ... 2.2), // offset factor.
                fogHazeColors[colorIndex][2], // color.
                7.0 // duration.
            ))
            clouds.append((
                0.4694, // cx.
                0.4694 * 0.0489 + 0.1500, // cy.
                0.3166, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.8 ... 2.2), // offset factor.
                fogHazeColors[colorIndex][2], // color.
                8.2 // duration.
            ))
            clouds.append((
                0.0250, // cx.
                0.0250 * 0.6820 + 0.1500, // cy.
                0.3166, // init radius.
                1.15, // scale ratio.
                Double.random(in: 1.8 ... 2.2), // offset factor.
                fogHazeColors[colorIndex][2], // color.
                7.7 // duration.
            ))
        }
        
        // stars in background.
        if type == .partlyCloudy && !daylight {
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
}

// MARK: - layers.

private struct CloudLayer: View {
    
    @State private var progress = 0.0
    private let animation: Animation
    
    private let cx: Double
    private let cy: Double
    private let radius: Double
    
    private let scaleRatio: Double
    private let offsetFactor: Double
    
    private let color: Color
    
    private let duration: Double
    
    private var width: Double
    private let rotation2D: Double
    private let rotation3D: Double
    
    init(
        model: CloudModel,
        index: Int,
        width: Double,
        rotation2D: Double,
        rotation3D: Double
    ) {
        // cx, cy, init radius, scale ratio, offset factor, color, duration.
        self.cx = model.clouds[index].0
        self.cy = model.clouds[index].1
        self.radius = model.clouds[index].2
        self.scaleRatio = model.clouds[index].3
        self.offsetFactor = model.clouds[index].4
        self.color = model.clouds[index].5
        self.duration = model.clouds[index].6
        
        self.width = width
        self.rotation2D = rotation2D
        self.rotation3D = rotation3D
        
        self.animation = Animation.easeInOut(
            duration: duration
        ).repeatForever(
            autoreverses: true
        )
    }
    
    var body: some View {
        Circle().fill(
            color,
            style: FillStyle()
        ).frame(
            width: CGFloat(2 * width * radius),
            height: CGFloat(2 * width * radius),
            alignment: .center
        ).scaleEffect(
            CGFloat(1 + (scaleRatio - 1) * progress)
        ).position(
            x: width * cx + getOffsetX(),
            y: width * cy + getOffsetY()
        ).onAppear {
            withAnimation(animation) {
                progress = 1.0
            }
        }
    }
    
    private func getOffsetX() -> Double {
        return sin(
            rotation2D * .pi / 180.0
        ) * 0.40 * width * radius * offsetFactor
    }
    
    private func getOffsetY() -> Double {
        return sin(
            rotation3D * .pi / 180.0
        ) * -0.50 * width * radius * offsetFactor
    }
}

private struct SingleStarLayer: View {
    
    @State private var opacity = 0.0
    private let animation: Animation
    
    let cx: Double
    let cy: Double
    let radius: Double
    
    let color: Color
    
    // fake state. (canvas size will change with the interface orientation)
    @State private var canvasSize: Double
    
    init(
        model: CloudModel,
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

private struct ThunderLayer: View {
    
    @State private var opacity = 0.0
    let daylight: Bool
    
    private let animation = Animation.linear(
        duration: 3.0
    )
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                daylight ? thunderDayColor : thunderNightColor,
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

struct CloudBackgroundView: View {
    
    let type: CloudType
    let daylight: Bool
    
    var body: some View {
        switch type {
        case .partlyCloudy:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? partlyCloudyDayBackgroundColors
                    : partlyCloudyNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        case .cloudy:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? cloudyDayBackgroundColors
                    : cloudyNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        case .thunder:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? thunderDayBackgroundColors
                    : thunderNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        case .fog:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? fogDayBackgroundColors
                    : fogNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        case .haze:
            return LinearGradient(
                gradient: Gradient(
                    colors: daylight
                    ? hazeDayBackgroundColors
                    : hazeNightBackgroundColors
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - preview.

struct Cloud_Previews: PreviewProvider {
        
    static let type = CloudType.haze
    static let daylight = true
    
    static var previews: some View {
        GeometryReader { proxy in
            CloudForegroundView(
                type: type,
                daylight: daylight,
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                paddingTop: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            CloudBackgroundView(type: type, daylight: daylight)
        ).ignoresSafeArea()
    }
}
