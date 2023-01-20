//
//  PrecipitationActivityWidget.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2023/1/18.
//

import ActivityKit
import WidgetKit
import SwiftUI
import GeometricWeatherCore
import GeometricWeatherTheme
import GeometricWeatherSettings

// MARK: - widget.

struct PrecipitationActivityWidget: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrecipitationActivityAttributes.self) { context in
            PrecipitationActivityNotificationView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    PrecipitationActivityIslandLeadingView(
                        context: context,
                        inIsland: true
                    )
                    .foregroundColor(self.getThemeColor(by: context))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    PrecipitationActivityIslandTrailingView(
                        context: context,
                        inIsland: true
                    )
                    .foregroundColor(self.getThemeColor(by: context))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    PrecipitationActivityIslandBottomView(
                        description: context.attributes.forecastDescription,
                        timezone: context.attributes.timezone,
                        minutely: context.attributes.minutely,
                        themeColor: self.getThemeColor(by: context),
                        primaryColor: .white,
                        secondaryColor: .white.opacity(0.5)
                    ).padding(
                        EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 4.0,
                            trailing: 0
                        )
                    )
                }
            } compactLeading: {
                UIImage.getWeatherIcon(
                    weatherCode: context.attributes.weatherCode,
                    daylight: context.attributes.isDaylight
                )?.resize(
                    to: CGSize(
                        width: normalWeatherIconSize,
                        height: normalWeatherIconSize
                    )
                )?.toImage()
            } compactTrailing: {
                Text(
                    SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                        context.attributes.temperature,
                        unit: "°"
                    )
                )
                    .multilineTextAlignment(.center)
                    .font(.body.weight(.bold))
                    .foregroundColor(
                        ThemeManager.weatherThemeDelegate.getThemeColor(
                            weatherKind: weatherCodeToWeatherKind(
                                code: context.attributes.weatherCode
                            ),
                            daylight: context.attributes.isDaylight
                        )
                    )
            } minimal: {
                UIImage.getWeatherIcon(
                    weatherCode: context.attributes.weatherCode,
                    daylight: context.attributes.isDaylight
                )?.resize(
                    to: CGSize(
                        width: normalWeatherIconSize,
                        height: normalWeatherIconSize
                    )
                )?.toImage()
            }
        }
    }
    
    private func getThemeColor(
        by context: ActivityViewContext<PrecipitationActivityAttributes>
    ) -> Color {
        return ThemeManager.weatherThemeDelegate.getThemeColor(
            weatherKind: weatherCodeToWeatherKind(
                code: context.attributes.weatherCode
            ),
            daylight: context.attributes.isDaylight
        )
    }
}

// MARK: - preview.

@available(iOS 16.2, *)
struct PrecipitationActivityWidget_Previews: PreviewProvider {
    
    static let attributes = PrecipitationActivityAttributes(
        locationName: "South of Market",
        locationFormattedId: "CURRENT_POSITION",
        isDaylight: true,
        isCurrentPosition: true,
        timestamp: Date().timeIntervalSince1970,
        timezone: .current,
        weatherText: "Heavy Rain",
        weatherCode: .rain(.heavy),
        temperature: 9,
        daytimeTemperature: 12,
        nighttimeTemperature: -2,
        forecastDescription: "降水将持续至少20分钟，20分钟雨渐小",
        minutely: Minutely(
            beginTime: Date().timeIntervalSince1970,
            endTime: Date().timeIntervalSince1970 + 2 * 60 * 60.0,
            precipitationIntensities: [
                1.0, 2.0, 5.0, 0.0, 1.0, 9.0, 2.0, 1.0, 1.0, 0.0, 0.0
            ]
        )
    )
    
    static let contentState = PrecipitationActivityAttributes.ContentState(
        currentTimeSince1970: Date().timeIntervalSince1970
    )

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
