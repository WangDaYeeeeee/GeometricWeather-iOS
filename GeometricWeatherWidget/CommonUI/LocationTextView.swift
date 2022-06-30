//
//  LocationTextView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/5/17.
//

import SwiftUI
import GeometricWeatherResources
import GeometricWeatherTheme
import WidgetKit

struct LocationTextView: View {
    
    let locationText: String
    let isCurrentLocation: Bool
    
    var body: some View {
        HStack(spacing: 4.0) {
            Text(self.locationText)
                .font(Font(miniCaptionFont).weight(.semibold))
                .foregroundColor(.white)
            
            if self.isCurrentLocation {
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 10.0, height: 10.0)
                    .foregroundColor(.white)
            }
        }
    }
}

struct LocationTextView_Previews: PreviewProvider {
    static var previews: some View {
        LocationTextView(
            locationText: "South Of Market",
            isCurrentLocation: true
        ).padding(
            [.all]
        ).background(
            ThemeManager.weatherThemeDelegate.getWidgetBackgroundView(
                weatherKind: .clear,
                daylight: true
            )
        ).previewContext(
            WidgetPreviewContext(family: .systemSmall)
        )
    }
}
