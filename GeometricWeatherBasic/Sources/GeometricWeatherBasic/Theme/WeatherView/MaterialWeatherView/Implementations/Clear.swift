//
//  Clear.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/16.
//

import SwiftUI

private let sunColor = Color.ColorFromRGB(0xfd5411)

private let backgroundColor1 = Color.ColorFromRGB(0xfdbc4c)
private let backgroundColor2 = Color.ColorFromRGB(0xff8300)

// MARK: - foreground.

struct ClearForegroundView: View {
    
    private let width: CGFloat
    private let height: CGFloat
    
    private let rotation2D: Double
    private let rotation3D: Double
    
    private let paddingTop: Double
    
    init(
        width: CGFloat,
        height: CGFloat,
        rotation2D: Double,
        rotation3D: Double,
        paddingTop: Double
    ) {
        self.width = width
        self.height = height
        self.rotation2D = rotation2D
        self.rotation3D = rotation3D
        self.paddingTop = paddingTop
    }
    
    var body: some View {
        let shortWidth = min(width, height)
        
        Group {
            // 1.
            SunLayer(
                period: 3.0,
                width: 0.47 * shortWidth,
                color: sunColor.opacity(0.4)
            )
            // 2.
            SunLayer(
                period: 4.0,
                width: 0.47 * shortWidth * 1.7794,
                color: sunColor.opacity(0.16)
            ).offset(
                x: 0.1 * getDeltaX(),
                y: 0.1 * getDeltaY()
            )
            // 3.
            SunLayer(
                period: 5.0,
                width: 0.47 * shortWidth * 3.0594,
                color: sunColor.opacity(0.08)
            ).offset(
                x: 0.2 * getDeltaX(),
                y: 0.2 * getDeltaY()
            )
        }.position(
            x: shortWidth,
            y: 0.0333 * shortWidth + paddingTop
        ).offset(
            x: (width - shortWidth) / 2.0 + getDeltaX(),
            y: getDeltaY()
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

private struct SunLayer: View {
    
    // animation.
    
    // the rotation degree of sun layer.
    @State private var rotationDegree = 0.0
    // rotation animation.
    private let animation: Animation
    
    // constants.
    
    private let width: CGFloat
    private let color: Color
    
    // life cycle.
    
    // period is the duration of sun to rotate 90 degree.
    init(
        period: Double,
        width: CGFloat,
        color: Color
    ) {
        self.animation = Animation.linear(
            duration: period
        ).repeatForever(
            autoreverses: false
        )
        
        self.width = CGFloat(width)
        self.color = color
    }
    
    var body: some View {
        ForEach(0 ..< 4) { i in
            Rectangle().fill(
                color,
                style: FillStyle()
            ).frame(
                width: width,
                height: width,
                alignment: .center
            ).rotationEffect(
                Angle(degrees: rotationDegree + 22.5 * Double(i))
            )
        }.onAppear {
            withAnimation(animation) {
                rotationDegree = 90.0
            }
        }
    }
}

// MARK: - background.

struct ClearBackgroundView: View {
    
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

struct ClearWidgetBackgroundView: View {
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.ColorFromRGB(0xf6c548),
                Color.ColorFromRGB(0xdc6300),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - preview.

struct Clear_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            ClearForegroundView(
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                paddingTop: 0.0
            )
        }.background(
            ClearBackgroundView()
        ).ignoresSafeArea()
    }
}
