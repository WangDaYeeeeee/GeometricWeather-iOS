//
//  PrecipitationActivityNotificationView.swift
//  GeometricWeatherLiveActivityExtension
//
//  Created by 王大爷 on 2023/1/18.
//

import WidgetKit
import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherTheme

struct PrecipitationActivityNotificationView: View {
    
    let context: ActivityViewContext<PrecipitationActivityAttributes>
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                PrecipitationActivityIslandLeadingView(context: self.context, inIsland: false)
                Spacer()
                PrecipitationActivityIslandTrailingView(context: self.context, inIsland: false)
            }
            .foregroundColor(.primary)
            .padding(.all)
            
            PrecipitationActivityIslandBottomView(
                description: self.context.attributes.forecastDescription,
                timezone: self.context.attributes.timezone,
                minutely: self.context.attributes.minutely,
                themeColor: ThemeManager.weatherThemeDelegate.getThemeColor(
                    weatherKind: weatherCodeToWeatherKind(
                        code: self.context.attributes.weatherCode
                    ),
                    daylight: self.context.attributes.isDaylight
                ),
                primaryColor: .primary,
                secondaryColor: .secondary
            )
            .padding([.top, .leading, .trailing, .bottom])
            .background(
                LinearGradient(
                    colors: [
                        (self.colorScheme == .light ? Color.white : Color.black).opacity(0.7),
                        (self.colorScheme == .light ? Color.white : Color.black).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}
