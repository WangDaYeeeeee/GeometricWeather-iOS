//
//  SettingsComponent.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/8.
//

import Foundation
import NeedleFoundation

protocol SettingsBuilder {
    
    var settingsViewController: SettingsViewController { get }
}

class SettingsComponent: Component<EmptyDependency>, SettingsBuilder {
    
    var settingsViewController: SettingsViewController {
        return SettingsViewController(param: ())
    }
}
