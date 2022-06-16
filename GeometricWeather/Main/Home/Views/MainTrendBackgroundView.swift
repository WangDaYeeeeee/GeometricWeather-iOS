//
//  MainTrendBackgroundView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/4/23.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import UIKit

class MainTrendBackgroundView: UIView {
    
    // MARK: - background subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let horizontalLinesView = HorizontalLinesBackgroundView(frame: .zero)
    
    // MARK: - background life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.weekLabel.text = "A"
        self.weekLabel.font = bodyFont
        self.weekLabel.textColor = .clear
        self.weekLabel.textAlignment = .center
        self.weekLabel.numberOfLines = 1
        self.addSubview(self.weekLabel)
        
        self.dateLabel.text = "A"
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .clear
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.addSubview(self.dateLabel)
        
        self.addSubview(self.horizontalLinesView)
        
        self.weekLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.weekLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.horizontalLinesView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        highLines: [HorizontalLine],
        lowLines: [HorizontalLine],
        lineColor: UIColor,
        paddingTop: Double = 0.0,
        paddingBottom: Double = 0.0
    ) {
        self.horizontalLinesView.highLines = highLines
        self.horizontalLinesView.lowLines = lowLines
        self.horizontalLinesView.lineColor = lineColor
        self.horizontalLinesView.paddingTop = paddingTop
        self.horizontalLinesView.paddingBottom = paddingBottom
    }
}

