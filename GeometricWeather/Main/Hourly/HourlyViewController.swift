//
//  HourlyViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/11/10.
//

import Foundation
import GeometricWeatherBasic

class HourlyViewController: GeoViewController<(
    weather: Weather,
    timezone: TimeZone,
    index: Int
)> {
    
    private lazy var subview = {
        return HourlyView(
            weather: self.param.weather,
            timezone: self.param.timezone,
            index: self.param.index
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.subview)
        
        self.subview.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    func measureAndSetPreferredContentSize() {
        self.preferredContentSize = self.subview.systemLayoutSizeFitting(.zero)
    }
}
