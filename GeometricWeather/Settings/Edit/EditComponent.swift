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
    
    private weak var scene: UIWindowScene?
    
    init(parent: Scope, scene: UIWindowScene?) {
        self.scene = scene
        super.init(parent: parent)
    }
    
    var editViewController: EditViewController {
        return EditViewController(param: (), in: self.scene)
    }
}
