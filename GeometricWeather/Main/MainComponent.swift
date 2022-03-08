//
//  MainComponent.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/8.
//

import Foundation
import NeedleFoundation

class MainComponent: BootstrapComponent {
    
    var mainViewModel: MainViewModel {
        return shared {
            MainViewModel()
        }
    }
    
    var mainViewController: MainViewController {
        return MainViewController(
            homeBuilder: self.homeComponent,
            managementBuilder: self.managementComponent
        )
    }
    
    var homeComponent: HomeComponent {
        return HomeComponent(parent: self)
    }
    
    var managementComponent: ManagementConponent {
        return ManagementConponent(parent: self)
    }
    
    var editComponent: EditComponent {
        return EditComponent(parent: self)
    }
    
    var settingsComponent: SettingsComponent {
        return SettingsComponent(parent: self)
    }
}
