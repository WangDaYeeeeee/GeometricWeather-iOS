//
//  GeoViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/16.
//

import Foundation
import GeometricWeatherBasic

class GeoViewController: UIViewController {
    
    // MARK: - status bar.
    
    var statusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    // MARK: - dark mode.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ThemeManager.shared.globalOverrideUIStyle.syncObserveValue(
            self.description
        ) { newValue in
            self.overrideUserInterfaceStyle = newValue
            
            if !self.isBeingPresented {
                let titleColor = self.view.traitCollection.userInterfaceStyle == .light
                ? UIColor.black
                : UIColor.white
                
                self.navigationController?.navigationBar.tintColor = .systemBlue
                self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: titleColor
                ]
                
                self.statusBarStyle = self.view.traitCollection.userInterfaceStyle == .light
                ? .darkContent
                : .lightContent
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ThemeManager.shared.globalOverrideUIStyle.stopObserve(
            self.description
        )
    }
}
