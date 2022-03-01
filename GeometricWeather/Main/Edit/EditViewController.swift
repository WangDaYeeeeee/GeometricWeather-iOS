//
//  EditViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/1.
//

import SwiftUI

private class EditHostingController: UIHostingController<EditView> {
    
    init() {
        super.init(rootView: EditView())
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EditViewController: GeoViewController<Void> {
    
    private let innerViewController = EditHostingController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = NSLocalizedString("settings_title_card_display", comment: "")
        
        self.addChild(self.innerViewController)
        self.view.addSubview(self.innerViewController.view)
        
        self.innerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

