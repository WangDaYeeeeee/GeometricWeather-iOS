//
//  MainViewController+Layout.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/10.
//

import Foundation
import GeometricWeatherBasic

extension MainViewController {
    
    func initSubviewsAndLayoutThem() {
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
        self.dragSwitchView.contentView.addSubview(self.tableView)
        
        self.navigationBarBackground.alpha = 0
        self.view.addSubview(self.navigationBarBackground)
        
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
        self.indicator.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(littleMargin * 3)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
