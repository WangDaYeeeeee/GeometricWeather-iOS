//
//  HomeComponent.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/8.
//

import Foundation
import NeedleFoundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

protocol HomeBuilder {
    
    func homeViewController(isSplitView splitView: Bool) -> HomeViewController
}

protocol HomeDependency: Dependency {
    
    var mainViewModel: MainViewModel { get }
    var editComponent: EditComponent { get }
    var settingsComponent: SettingsComponent { get }
}

class HomeComponent: Component<HomeDependency>, HomeBuilder {
    
    func homeViewController(isSplitView splitView: Bool) -> HomeViewController {
        return HomeViewController(
            vm: self.dependency.mainViewModel,
            splitView: splitView,
            editBuilder: self.dependency.editComponent,
            settingsBuilder: self.dependency.settingsComponent
        )
    }
}
