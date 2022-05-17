//
//  MainComponent.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/8.
//

import Foundation
import NeedleFoundation

class MainComponent: BootstrapComponent {
    
    private weak var scene: UIWindowScene?
    
    init(scene: UIWindowScene) {
        self.scene = scene
        super.init()
    }
    
    var mainViewModel: MainViewModel {
        return shared {
            MainViewModel(scene: self.scene)
        }
    }
    
    var mainViewController: MainViewController {
        return MainViewController(
            scene: self.scene,
            homeBuilder: self.homeComponent,
            managementBuilder: self.managementComponent
        )
    }
    
    var homeComponent: HomeComponent {
        return HomeComponent(parent: self)
    }
    
    var managementComponent: ManagementConponent {
        return ManagementConponent(parent: self, scene: self.scene)
    }
    
    var editComponent: EditComponent {
        return EditComponent(parent: self, scene: self.scene)
    }
    
    var settingsComponent: SettingsComponent {
        return SettingsComponent(parent: self, scene: self.scene)
    }
}
