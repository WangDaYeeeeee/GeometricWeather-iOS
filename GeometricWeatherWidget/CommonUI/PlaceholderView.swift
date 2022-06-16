//
//  PlaceholderView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/4/24.
//

import SwiftUI
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherTheme

struct PlaceholderView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(namedInBasic: "launch_icon")?
                    .resizable()
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                Spacer()
            }
            Spacer()
        }.background(
            ZStack {
                if isDaylight() {
                    Color.white
                } else {
                    Color.black
                }
                
                ThemeManager
                    .weatherThemeDelegate
                    .getWidgetBackgroundView(
                        weatherKind: weatherCodeToWeatherKind(code: .clear),
                        daylight: isDaylight()
                    )
                    .opacity(0.33)
            }
        )
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView().previewContext(
            WidgetPreviewContext(family: .systemMedium)
        )
    }
}
