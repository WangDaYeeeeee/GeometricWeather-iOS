//
//  MainView.swift
//  GeometricWeatherWatch WatchKit Extension
//
//  Created by 王大爷 on 2022/5/2.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherTheme

struct MainView: View {
    
    var body: some View {
        GeometryReader { proxy in
            MainHeaderView(
                currentTemperature: 56,
                currentWeatherCode: .clear,
                currentDaylight: true,
                currentWeatherText: "Clear",
                currentSubtitle: "Middle pollution",
                screenSize: proxy.size
            )
        }.ignoresSafeArea()
            .navigationTitle {
                MainNavigationTitleView(
                    locationText: "Beijing",
                    isCurrentLocation: true
                )
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView()
        }
    }
}
