//
//  MainNavigationTitleView.swift
//  GeometricWeatherWatch WatchKit Extension
//
//  Created by 王大爷 on 2022/5/10.
//

import SwiftUI
import GeometricWeatherResources

struct MainNavigationTitleView: View {
    
    let locationText: String
    let isCurrentLocation: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Text(self.locationText)
                .font(Font(bodyFont))
            if self.isCurrentLocation {
                Image(systemName: "location.fill")
                    .resizable()
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 10, height: 10)
            }
            
            Spacer()
        }
    }
}

struct MainNavigationTitleView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationTitleView(
            locationText: "Beijing",
            isCurrentLocation: true
        )
    }
}
