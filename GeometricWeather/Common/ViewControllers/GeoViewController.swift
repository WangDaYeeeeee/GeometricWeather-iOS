//
//  GeoViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/16.
//

import Foundation
import GeometricWeatherBasic

class GeoViewController<T>: UIViewController {
    
    // MARK: - parameter.
    
    let param: T
    
    init(param: T) {
        self.param = param
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        ThemeManager.shared.globalOverrideUIStyle.syncAddObserver(
            self
        ) { newValue in
            self.overrideUserInterfaceStyle = newValue
            
            if !self.isBeingPresented {
                let titleColor = self.view.traitCollection.userInterfaceStyle == .light
                ? UIColor.black
                : UIColor.white
                
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.navigationBar.tintColor = .systemBlue
                self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: titleColor
                ]
                self.navigationController?.navigationBar.setBackgroundImage(
                    nil,
                    for: .default
                )
                self.navigationController?.navigationBar.shadowImage = nil
                
                self.statusBarStyle = self.view.traitCollection.userInterfaceStyle == .light
                ? .darkContent
                : .lightContent
            }
        }
    }
}
