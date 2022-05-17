//
//  GeoViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/16.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import UIKit

class GeoViewController<T>: UIViewController {
    
    // MARK: - parameter.
    
    let param: T
    private(set) weak var scene: UIWindowScene?
    
    init(param: T, in scene: UIWindowScene?) {
        self.param = param
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - navigation bar style.
    
    var preferLargeTitle: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = self.preferLargeTitle ? .always : .never
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
        
        self.scene?.themeManager.globalOverrideUIStyle.syncAddObserver(self) { [weak self] newValue in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.overrideUserInterfaceStyle = newValue
            
            if !strongSelf.isBeingPresented {
                let titleColor = strongSelf.view.traitCollection.userInterfaceStyle == .light
                ? UIColor.black
                : UIColor.white
                
                strongSelf.navigationController?.navigationBar.isTranslucent = true
                strongSelf.navigationController?.navigationBar.tintColor = .systemBlue
                strongSelf.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: titleColor
                ]
                strongSelf.navigationController?.navigationBar.setBackgroundImage(
                    nil,
                    for: .default
                )
                strongSelf.navigationController?.navigationBar.shadowImage = nil
                
                strongSelf.statusBarStyle = strongSelf.view.traitCollection.userInterfaceStyle == .light
                ? .darkContent
                : .lightContent
            }
        }
    }
    
    // MARK: - split view controller compat.
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let titleView = self.navigationItem.titleView {
            self.navigationItem.titleView = nil
            self.navigationItem.titleView = titleView
        }
        
        self.statusBarStyle = self.view.traitCollection.userInterfaceStyle == .light
        ? .darkContent
        : .lightContent
        
        let titleColor = self.view.traitCollection.userInterfaceStyle == .light
        ? UIColor.black
        : UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: titleColor
        ]
    }
}
