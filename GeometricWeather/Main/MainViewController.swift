//
//  MainViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/2.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class MainViewController: UISplitViewController {
    
    private weak var scene: UIWindowScene?
    private let managementBuilder: ManagementBuilder
    private let showDoubleColumn = isTablet()
    
    // MARK: - life cycle.
    
    init(
        scene: UIWindowScene?,
        homeBuilder: HomeBuilder,
        managementBuilder: ManagementBuilder
    ) {
        self.scene = scene
        self.managementBuilder = managementBuilder
        super.init(style: .doubleColumn)
        
        self.preferredDisplayMode = self.showDoubleColumn ? .automatic : .secondaryOnly
        self.presentsWithGesture = true
        
        if self.showDoubleColumn {
            self.setViewController(
                GeoNavigationController(
                    rootViewController: managementBuilder.splitManagementViewController
                ),
                for: .primary
            )
        }
        self.setViewController(
            GeoNavigationController(
                rootViewController: homeBuilder.homeViewController(
                    isSplitView: self.showDoubleColumn
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
        
        self.scene?.themeManager.globalOverrideUIStyle.addObserver(
            self
        ) { [weak self] newValue in
            self?.overrideUserInterfaceStyle = newValue
        }
        
        self.scene?.eventBus.register(
            self,
            for: TimeBarManagementAction.self
        ) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.showDoubleColumn {
                strongSelf.show(.primary)
                return
            }
            
            guard let secondaryNavigationViewController = strongSelf.viewController(
                for: .secondary
            ) as? UINavigationController else {
                return
            }
            
            if secondaryNavigationViewController.presentedViewController != nil {
                return
            }
            
            secondaryNavigationViewController.present(
                strongSelf.managementBuilder.presentManagementViewController,
                animated: true,
                completion: nil
            )
        }
        
        self.scene?.eventBus.register(
            self,
            for: SplitManagementViewDismissEvent.self
        ) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            if !strongSelf.showDoubleColumn {
                return
            }
            
            if strongSelf.splitBehavior == .overlay {
                strongSelf.show(.secondary)
            }
        }
    }
}
