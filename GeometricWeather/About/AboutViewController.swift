//
//  AboutViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import SwiftUI

// MARK: - swift UI bridge.

private class InnerAboutViewController: UIHostingController<AboutView> {
    
    init() {
        super.init(rootView: AboutView())
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - interface.

class AboutViewController: GeoViewController<Void> {
    
    private let innerViewController = InnerAboutViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = NSLocalizedString("action_about", comment: "")
        
        self.addChild(self.innerViewController)
        self.view.addSubview(self.innerViewController.view)
        
        self.innerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func onBackButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
}
