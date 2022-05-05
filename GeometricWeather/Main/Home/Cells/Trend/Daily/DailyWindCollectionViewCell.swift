//
//  DailyWindCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/24.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private func toRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180.0
}

class DailySingleWindCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let dailyIcon = UIImageView(frame: .zero)
    private let histogramView = HistogramView(frame: .zero)
    
    // MARK: - inner data.
    
    var trendPaddingTop: CGFloat {
        get {
            return self.histogramView.paddingTop
        }
        set {
            self.histogramView.paddingTop = newValue
        }
    }
    
    var trendPaddingBottom: CGFloat {
        get {
            return self.histogramView.paddingBottom
        }
        set {
            self.histogramView.paddingBottom = newValue
        }
    }
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.weekLabel.font = bodyFont
        self.weekLabel.textColor = .label
        self.weekLabel.textAlignment = .center
        self.weekLabel.numberOfLines = 1
        self.contentView.addSubview(self.weekLabel)
        
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .secondaryLabel
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.contentView.addSubview(self.dateLabel)
        
        self.dailyIcon.contentMode = .center
        self.contentView.addSubview(self.dailyIcon)
        
        self.contentView.addSubview(self.histogramView)
        
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
        self.dailyIcon.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.dailyIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.histogramView.snp.makeConstraints { make in
            make.top.equalTo(self.dailyIcon.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        daily: Daily,
        maxWindSpeed: Double,
        timezone: TimeZone
    ) {
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? getLocalizedText("today")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: getLocalizedText("date_format_short")
        )
        
        if !(daily.wind?.degree.noDirection ?? true) {
            self.dailyIcon.image = UIImage(
                systemName: "arrow.down"
            )?.withTintColor(
                .label
            ).scaleToSize(
                CGSize(
                    width: mainWindIconSize,
                    height: mainWindIconSize
                )
            )
            self.dailyIcon.transform = CGAffineTransform(
                rotationAngle: toRadians(daily.wind?.degree.degree ?? 0.0)
            )
        } else {
            self.dailyIcon.image = UIImage(
                systemName: "arrow.up.and.down.and.arrow.left.and.right"
            )?.withTintColor(
                .label
            ).scaleToSize(
                CGSize(
                    width: mainWindIconSize,
                    height: mainWindIconSize
                )
            )
            self.dailyIcon.transform = CGAffineTransform(rotationAngle: 0.0)
        }
        
        if maxWindSpeed > 0 {
            self.histogramView.highValue = (daily.wind?.speed ?? 0.0) / maxWindSpeed
        } else {
            self.histogramView.highValue = 0.0
        }
        self.histogramView.lowValue = nil
        
        let speedUnit = SettingsManager.shared.speedUnit
        self.histogramView.highDescription = (
            speedUnit.formatValueWithUnit(
                daily.wind?.speed ?? 0.0,
                unit: ""
            ),
            ""
        )
        self.histogramView.color = getLevelColor(
            daily.wind?.getWindLevel() ?? 1
        )
    }
}
