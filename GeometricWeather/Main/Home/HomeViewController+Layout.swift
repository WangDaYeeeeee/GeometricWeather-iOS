//
//  HomeViewController+Layout.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/10.
//

import Foundation
import GeometricWeatherBasic

extension HomeViewController {
    
    func initSubviewsAndLayoutThem() {
        self.view.backgroundColor = .systemBackground
        
        if !self.splitView {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "building.2.crop.circle"),
                style: .plain,
                target: self,
                action: #selector(self.onManagementButtonClicked)
            )
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(self.onSettingsButtonClicked)
        )
        self.navigationItem.title = getLocalizedText("action_home")
        self.navigationItem.titleView = self.navigationBarTitleView
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.weatherViewController.view.backgroundColor = .clear
        self.addChild(self.weatherViewController)
        self.view.addSubview(self.weatherViewController.view)
        
        self.dragSwitchView.delegate = self
        self.view.addSubview(self.dragSwitchView)
        
        self.cellCache = self.prepareCellCache()
        self.tableView.backgroundColor = .clear
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.tintColor = .white
        self.tableView.refreshControl?.addTarget(
            self,
            action: #selector(self.onPullRefresh),
            for: .valueChanged
        )
        self.tableView.hideKeyboardExecutor = {
            EventBus.shared.post(HideKeyboardEvent())
        }
        self.dragSwitchView.contentView.addSubview(self.tableView)
        
        self.navigationBarBackground.alpha = 0
        self.view.addSubview(self.navigationBarBackground)
        
        self.navigationBarBackgroundShadow.alpha = 0
        self.navigationBarBackgroundShadow.backgroundColor = .opaqueSeparator.withAlphaComponent(0.5)
        self.view.addSubview(self.navigationBarBackgroundShadow)
        
        self.indicator.alpha = 0
        self.view.addSubview(self.indicator)
        
        self.weatherViewController.view.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.dragSwitchView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.tableView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.navigationBarBackground.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
        }
        self.navigationBarBackgroundShadow.snp.makeConstraints { make in
            make.top.equalTo(self.navigationBarBackground.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.indicator.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(littleMargin * 3)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
