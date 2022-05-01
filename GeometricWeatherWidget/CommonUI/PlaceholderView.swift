//
//  PlaceholderView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/4/24.
//

import SwiftUI
import GeometricWeatherBasic
import WidgetKit

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
            ZStack {
                if isDaylight() {
                    Color.white
                } else {
                    Color.black
                }
                
                ThemeManager
                    .shared
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
