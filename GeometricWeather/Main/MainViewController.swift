//
//  MainViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/2.
//

import Foundation
import GeometricWeatherBasic

class MainViewController: UISplitViewController {
    
    private let viewModel = MainViewModel()
    
    // MARK: - life cycle.
    
    init() {
        super.init(style: .doubleColumn)
        
        self.preferredDisplayMode = isTablet() ? .automatic : .secondaryOnly
        self.presentsWithGesture = true
        
        if isTablet() {
            self.setViewController(
                GeoNavigationController(
                    rootViewController: SplitManagementViewController(
                        param: MainViewModelWeakRef(vm: self.viewModel)
                    )
                ),
                for: .primary
            )
        }
        self.setViewController(
            GeoNavigationController(
                rootViewController: HomeViewController(
                    vmWeakRef: MainViewModelWeakRef(vm: self.viewModel),
                    splitView: isTablet()
                )
            ),
            for: .secondary
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.shared.globalOverrideUIStyle.addObserver(self) { newValue in
            self.overrideUserInterfaceStyle = newValue
        }
    }
}
