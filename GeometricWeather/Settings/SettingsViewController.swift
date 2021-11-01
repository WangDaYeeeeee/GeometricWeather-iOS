//
//  SettingsViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI
import GeometricWeatherBasic

// MARK: - swift UI bridge.

private class InnerSettingsViewController: UIHostingController<SettingsView> {
    
    init() {
        super.init(rootView: SettingsView())
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printLog(keyword: "testing", content: "de init")
    }
}

// MARK: - interface.

class SettingsViewController: GeoViewController<Void> {
    
    private let innerViewController = InnerSettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = NSLocalizedString("action_settings", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(self.onAboutButtonClicked)
        )
        
        self.addChild(self.innerViewController)
        self.view.addSubview(self.innerViewController.view)
        
        self.innerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func onBackButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func onAboutButtonClicked() {
        self.navigationController?.pushViewController(
            AboutViewController(param: ()),
            animated: true
        )
    }
}
