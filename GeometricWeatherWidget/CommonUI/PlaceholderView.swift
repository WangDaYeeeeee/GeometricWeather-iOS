//
//  PlaceholderView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/4/24.
//

import SwiftUI
import GeometricWeatherBasic

struct PlaceholderView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(
                    uiImage: UIImage(namedInBasic: "launch_icon")!
                        .scaleToSize(CGSize(width: 96.0, height: 96.0))!
                )
                Spacer()
            }
            Spacer()
        }.background(
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackgroundView(
                weatherKind: weatherCodeToWeatherKind(code: .clear),
                daylight: isDaylight()
            )
        )
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
