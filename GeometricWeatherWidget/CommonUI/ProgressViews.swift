//
//  ProgressViews.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/4/30.
//

import SwiftUI
import WidgetKit
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherTheme

private let circularProgressInnerMargin = 6.0
private let circularProgressProgressWidth = 12.0

private let linearProgressInnerMargin = 2.0
private let linearProgressProgressWidth = 4.0

private let shadowAlpha = 0.1
private let shadowOpacity = 0.5

// MARK: - circular progress view.

struct CircularProgressView: View {
    
    let value: UInt
    let total: UInt
    let description: String
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CircularProgressLayer(
                    progress: 1.0,
                    color: progressBackground,
                    canvasSize: proxy.size
                )
                CircularProgressLayer(
                    progress: Double(self.value) / Double(self.total),
                    color: self.color,
                    canvasSize: proxy.size
                ).shadow(
                    color: self.color.opacity(shadowOpacity),
                    radius: 6.0,
                    x: 0.0,
                    y: 4.0
                )
                Text(String(self.value))
                    .font(
                        .system(
                            size: 42.0,
                            weight: .medium,
                            design: .default
                        )
                    )
                    .foregroundColor(.white)
                Text(self.description)
                    .font(Font(captionFont))
                    .foregroundColor(.white.opacity(0.5))
                    .position(
                        x: proxy.size.width / 2.0,
                        y: proxy.size.height - 10.0
                    )
            }
        }
    }
}

private struct CircularProgressLayer: View {
    
    let progress: Double
    let color: Color
    let canvasSize: CGSize
    
    var safeProgress: Double {
        return max(
            0.0,
            min(self.progress, 1.0)
        )
    }
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.75 * self.safeProgress)
            .rotation(.radians(0.75 * .pi))
            .stroke(
                self.color,
                style: StrokeStyle(
                    lineWidth: circularProgressProgressWidth,
                    lineCap: .round
                )
            )
            .frame(
                width: min(
                    self.canvasSize.width,
                    self.canvasSize.height
                )
                - circularProgressInnerMargin * 2
                - circularProgressProgressWidth,
                height: min(
                    self.canvasSize.width,
                    self.canvasSize.height
                )
                - circularProgressInnerMargin * 2
                - circularProgressProgressWidth
            )
            .position(
                x: self.canvasSize.width / 2.0,
                y: self.canvasSize.height / 2.0
            )
    }
}

// MARK: - linear progress view.

struct LinearProgressView: View {
    
    let value: UInt
    let total: UInt
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(self.title)
                .font(Font(captionFont))
                .foregroundColor(.white)
            GeometryReader { proxy in
                ZStack {
                    LinearProgressLayer(
                        progress: 1.0,
                        color: progressBackground,
                        canvasSize: proxy.size
                    )
                    LinearProgressLayer(
                        progress: Double(self.value) / Double(self.total),
                        color: self.color,
                        canvasSize: proxy.size
                    ).shadow(
                        color: self.color.opacity(shadowOpacity),
                        radius: 3.0,
                        x: 0.0,
                        y: 2.0
                    )
                }
            }.frame(
                height: linearProgressProgressWidth
                + 2 * linearProgressInnerMargin
            )
            HStack(alignment: .center, spacing: 0.0) {
                Spacer()
                Text(self.description)
                    .font(Font(miniCaptionFont))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

private struct LinearProgressLayer: View {
    
    let progress: Double
    let color: Color
    let canvasSize: CGSize

    var safeProgress: Double {
        return max(
            0.0,
            min(self.progress, 1.0)
        )
    }
    
    var body: some View {
        Path { path in
            path.move(
                to: CGPoint(
                    x: linearProgressInnerMargin,
                    y: self.canvasSize.height / 2.0
                )
            )
            path.addLine(
                to: CGPoint(
                    x: linearProgressInnerMargin + (
                        self.canvasSize.width - 2 * linearProgressInnerMargin
                    ) * self.safeProgress,
                    y: self.canvasSize.height / 2.0
                )
            )
        }.stroke(
            self.color,
            style: StrokeStyle(
                lineWidth: linearProgressProgressWidth,
                lineCap: .round
            )
        )
    }
}

// MARK: - preview.

struct ProgressViews_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            HStack {
                CircularProgressView(
                    value: 300,
                    total: 400,
                    description: "Strong",
                    color: .red
                ).frame(
                    width: proxy.size.width * 0.5,
                    alignment: .leading
                )
                LinearProgressView(
                    value: 300,
                    total: 400,
                    title: "PM2.5",
                    description: "Strong",
                    color: .red
                ).frame(
                    width: proxy.size.width * 0.5,
                    alignment: .trailing
                )
            }
        }.background(
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackgroundView(
                weatherKind: .wind, daylight: true
            )
        ).previewContext(
            WidgetPreviewContext(family: .systemMedium)
        )
    }
}
