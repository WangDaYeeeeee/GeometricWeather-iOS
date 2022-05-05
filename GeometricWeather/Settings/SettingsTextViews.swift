//
//  SettingsTextViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct SettingsTitleView: View {
    
    let key: String
    
    var body: some View {
        Text(
            getLocalizedText(key)
        ).font(
            Font(titleFont)
        ).foregroundColor(
            Color(UIColor.label)
        )
    }
}

struct SettingsBodyView: View {
    
    let key: String
    
    var body: some View {
        Text(
            getLocalizedText(key)
        ).font(
            Font(bodyFont)
        ).foregroundColor(
            Color(UIColor.secondaryLabel)
        )
    }
}

struct SettingsCaptionView: View {
    
    let key: String
    
    var body: some View {
        Text(
            getLocalizedText(key)
        ).font(
            Font(captionFont)
        ).foregroundColor(
            Color(UIColor.tertiaryLabel)
        )
    }
}

struct SettingsTextViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SettingsTitleView(key: "settings_title_background_free")
            SettingsBodyView(key: "settings_title_background_free")
            SettingsCaptionView(key: "settings_title_background_free")
        }
    }
}
