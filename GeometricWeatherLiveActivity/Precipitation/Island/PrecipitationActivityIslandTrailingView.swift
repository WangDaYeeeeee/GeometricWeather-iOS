//
//  PrecipitationActivityIslandTrailingView.swift
//  GeometricWeatherLiveActivityExtension
//
//  Created by 王大爷 on 2023/1/19.
//

import SwiftUI
import WidgetKit
import GeometricWeatherTheme
import GeometricWeatherSettings

struct PrecipitationActivityIslandTrailingView: View {
    
    let context: ActivityViewContext<PrecipitationActivityAttributes>
    let inIsland: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0.0) {
            Text(
                SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    self.context.attributes.temperature,
                    unit: "º"
                )
            )
            .font(
                (self.inIsland ? Font.title : Font.largeTitle).weight(.semibold)
            )
            .frame(height: 36.0)
            
            if !self.inIsland {
                VStack(alignment: .trailing, spacing: 2.0) {
                    Text(
                        SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            self.context.attributes.daytimeTemperature,
                            unit: "°"
                        )
                    ).font(.caption2.weight(.bold))
                    
                    Text(
                        SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            self.context.attributes.nighttimeTemperature,
                            unit: "°"
                        )
                    ).font(.caption2.weight(.bold))
                        .opacity(secondaryTextOpacity)
                }
            }
        }
        .lineLimit(1)
    }
}
