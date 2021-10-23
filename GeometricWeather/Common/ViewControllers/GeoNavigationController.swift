//
//  GeoNavigationController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

class GeoNavigationController: UINavigationController,
                                UINavigationControllerDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
        
        ThemeManager.shared.homeOverrideUIStyle.syncObserveValue(
            self
        ) { [weak self] newValue in
            self?.setUserInterfaceStyle()
        }
        ThemeManager.shared.globalOverrideUIStyle.syncObserveValue(
            self
        ) { [weak self] newValue in
            self?.setUserInterfaceStyle()
        }
    }
    
    deinit {
        ThemeManager.shared.globalOverrideUIStyle.stopObserve(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    private func setUserInterfaceStyle() {
        let style = self.topViewController?.isKind(
            of: MainViewController.self
        ) ?? false
        ? ThemeManager.shared.homeOverrideUIStyle.value
        : ThemeManager.shared.globalOverrideUIStyle.value
        
        if self.overrideUserInterfaceStyle != style {
            self.overrideUserInterfaceStyle = style
        }
    }
    
    // MARK: - delegate.
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        self.setUserInterfaceStyle()
    }
}
