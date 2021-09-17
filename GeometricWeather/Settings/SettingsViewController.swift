//
//  SettingsViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI

// MARK: - swift UI bridge.

private class InnerSettingsViewController: UIHostingController<SettingsView> {
    
    init() {
        super.init(rootView: SettingsView())
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - interface.

class SettingsViewController: GeoViewController {
    
    private let innerViewController = InnerSettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = NSLocalizedString("action_settings", comment: "")
        
        self.addChild(self.innerViewController)
        self.view.addSubview(self.innerViewController.view)
        
        self.innerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func onBackButtonClicked() {
        if let parent = self.navigationController {
            parent.popViewController(animated: true)
        }
    }
}
