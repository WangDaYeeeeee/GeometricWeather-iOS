//
//  MainViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/2.
//

import Foundation
import GeometricWeatherBasic

class MainViewController: UISplitViewController {
    
    // MARK: - life cycle.
    
    init(
        homeBuilder: HomeBuilder,
        managementBuilder: ManagementBuilder
    ) {
        super.init(style: .doubleColumn)
        
        self.preferredDisplayMode = isTablet() ? .automatic : .secondaryOnly
        self.presentsWithGesture = true
        
        let splitable = isTablet()
        
        if splitable {
            self.setViewController(
                GeoNavigationController(
                    rootViewController: managementBuilder.splitManagementViewController
                ),
                for: .primary
            )
        }
        self.setViewController(
            GeoNavigationController(
                rootViewController: homeBuilder.homeViewController(isSplitView: splitable)
            ),
            for: .secondary
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.shared.globalOverrideUIStyle.addObserver(
            self
        ) { [weak self] newValue in
            self?.overrideUserInterfaceStyle = newValue
        }
    }
}
