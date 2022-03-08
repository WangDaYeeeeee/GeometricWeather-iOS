//
//  EditComponent.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/8.
//

import Foundation
import NeedleFoundation

protocol EditBuilder {
    
    var editViewController: EditViewController { get }
}

class EditComponent: Component<EmptyDependency>, EditBuilder {
    
    var editViewController: EditViewController {
        return EditViewController(param: ())
    }
}
