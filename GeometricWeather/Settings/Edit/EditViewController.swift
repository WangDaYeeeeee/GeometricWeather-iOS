//
//  EditViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/1.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class EditViewController: GeoViewController<Void> {
    
    private let editViewModel = EditViewModel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = getLocalizedText("settings_title_card_display")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.counterclockwise"),
            style: .plain,
            target: self,
            action: #selector(self.onResetButtonTapped)
        )
        
        let editViewController = UIHostingController<EditView>(
            rootView: EditView(model: self.editViewModel)
        )
        self.addChild(editViewController)
        self.view.addSubview(editViewController.view)
        
        editViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.editViewModel.isDefaultMainCardList.addObserver(
            self
        ) { [weak self] newValue in
            self?.navigationItem.rightBarButtonItem?.isEnabled = !newValue
        }
    }
    
    @objc private func onResetButtonTapped() {
        self.editViewModel.resetToDefault()
    }
}

