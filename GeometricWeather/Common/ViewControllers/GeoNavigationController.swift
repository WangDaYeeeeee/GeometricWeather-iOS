//
//  GeoNavigationController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit

struct PresentViewControllerEvent {
    weak var viewController: UIViewController?
}

class GeoNavigationController: UINavigationController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.prefersLargeTitles = true
        self.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
        self.view.window?.windowScene?.eventBus.post(
            PresentViewControllerEvent(viewController: viewControllerToPresent)
        )
    }
}
