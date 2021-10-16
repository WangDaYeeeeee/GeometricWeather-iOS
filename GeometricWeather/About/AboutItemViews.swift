//
//  AboutItemViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import SwiftUI
import GeometricWeatherBasic

struct AboutHeader: View {
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 8) {
                Image(
                    uiImage: UIImage(
                        named: "launch_icon"
                    )!.scaleToSize(
                        CGSize(width: 156, height: 156)
                    )!
                ).frame(
                    width: 156,
                    height: 156,
                    alignment: .center
                )
                
                Text(
                    "GeometricWeather"
                ).font(
                    Font(largeTitleFont)
                ).foregroundColor(
                    Color(UIColor.label)
                )
                
                Text(
                    Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                ).font(
                    Font(captionFont)
                ).foregroundColor(
                    Color(UIColor.tertiaryLabel)
                )
                
                Color.black.opacity(0.0).frame(
                    width: 0.0,
                    height: 2.0,
                    alignment: .center
                )
            }
            
            Spacer()
        }
    }
}

struct AboutSectionTitle: View {
    
    let key: String
    
    var body: some View {
        Text(
            NSLocalizedString(key, comment: "")
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
                NSLocalizedString(key, comment: "")
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
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(
                self.title
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
            
            Text(
                self.content
            ).font(
                Font(bodyFont)
            ).foregroundColor(
                Color(UIColor.secondaryLabel)
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
