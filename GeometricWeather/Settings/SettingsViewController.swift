//
//  SettingsViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class SettingsViewController: GeoViewController<Void> {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = getLocalizedText("action_settings")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(self.onAboutButtonClicked)
        )
        
        let settingsViewController = UIHostingController<SettingsView>(
            rootView: SettingsView()
        )
        self.addChild(settingsViewController)
        self.view.addSubview(settingsViewController.view)
        
        settingsViewController.view.snp.makeConstraints { make in
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
