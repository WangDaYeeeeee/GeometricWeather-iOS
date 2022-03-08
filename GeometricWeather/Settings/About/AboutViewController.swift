//
//  AboutViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import SwiftUI

class AboutViewController: GeoViewController<Void> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = NSLocalizedString("action_about", comment: "")
        
        let aboutViewController = UIHostingController<AboutView>(
            rootView: AboutView()
        )
        self.addChild(aboutViewController)
        self.view.addSubview(aboutViewController.view)
        
        aboutViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func onBackButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
}
