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
        let showDoubleColumn = isTablet()
        
        self.preferredDisplayMode = showDoubleColumn ? .automatic : .secondaryOnly
        self.presentsWithGesture = true
        
        if showDoubleColumn {
            self.setViewController(
                GeoNavigationController(
                    rootViewController: managementBuilder.splitManagementViewController
                ),
                for: .primary
            )
        }
        self.setViewController(
            GeoNavigationController(
                rootViewController: homeBuilder.homeViewController(isSplitView: showDoubleColumn)
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
