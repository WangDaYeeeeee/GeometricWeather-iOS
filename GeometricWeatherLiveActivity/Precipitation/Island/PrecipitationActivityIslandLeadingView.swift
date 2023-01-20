//
//  PrecipitationActivityIslandLeadingView.swift
//  GeometricWeatherLiveActivityExtension
//
//  Created by 王大爷 on 2023/1/19.
//

import SwiftUI
import WidgetKit
import GeometricWeatherTheme
import GeometricWeatherResources

struct PrecipitationActivityIslandLeadingView: View {
    
    let context: ActivityViewContext<PrecipitationActivityAttributes>
    let inIsland: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4.0) {
            UIImage.getWeatherIcon(
                weatherCode: self.context.attributes.weatherCode,
                daylight: self.context.attributes.isDaylight
            )?.resize(
                to: CGSize(width: 36.0, height: 36.0)
            )?.toImage()
            
            if !self.inIsland {
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(self.context.attributes.weatherText)
                        .font(.caption.weight(.bold))
                    
                    HStack(alignment: .center, spacing: 4.0) {
                        Text(self.context.attributes.locationName)
                            .lineLimit(1)
                            .font(.caption.weight(.medium))
                        
                        Image(systemName: "location.fill")
                            .resizable()
                            .frame(width: 8.0, height: 8.0)
                    }.opacity(0.5)
                }
            }
        }
    }
}
