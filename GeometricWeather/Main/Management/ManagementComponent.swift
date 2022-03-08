//
//  ManagementComponent.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/8.
//

import Foundation
import NeedleFoundation

protocol ManagementBuilder {
    
    var presentManagementViewController: PresentManagementViewController { get }
    var splitManagementViewController: SplitManagementViewController { get }
}

protocol ManagementDependency: Dependency {
    
    var mainViewModel: MainViewModel { get }
}

class ManagementConponent: Component<ManagementDependency>, ManagementBuilder {
    
    var presentManagementViewController: PresentManagementViewController {
        return PresentManagementViewController(param: self.dependency.mainViewModel)
    }
    
    var splitManagementViewController: SplitManagementViewController {
        return SplitManagementViewController(param: self.dependency.mainViewModel)
    }
}
