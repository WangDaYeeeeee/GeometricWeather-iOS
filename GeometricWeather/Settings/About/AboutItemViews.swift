//
//  AboutItemViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct AboutHeader: View {
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 8) {
                Image(namedInBasic: "launch_icon")?
                    .resizable()
                    .frame(width: 156, height: 156)
                
                Text(getLocalizedText("GeometricWeather"))
                    .font(Font(largeTitleFont))
                    .foregroundColor(Color(UIColor.label))
                
                Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "--")
                    .font(Font(captionFont))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                
                Color
                    .black
                    .opacity(0.0)
                    .frame(width: 0.0, height: 2.0)
            }
            
            Spacer()
        }
    }
}

struct AboutSectionTitle: View {
    
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

struct AboutAppItem: View {
    
    let icon: String
    let key: String
    
    var body: some View {
        HStack {
            Image(systemName: self.icon)
            
            Text(
                getLocalizedText(key)
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
        }.padding(
            EdgeInsets(
                top: littleMargin,
                leading: littleMargin,
                bottom: littleMargin,
                trailing: littleMargin
            )
        )
    }
}

struct ThanksItem: View {
    
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(
                self.title
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
        }.padding(
            EdgeInsets(
                top: littleMargin,
                leading: littleMargin,
                bottom: littleMargin,
                trailing: littleMargin
            )
        )
    }
}
