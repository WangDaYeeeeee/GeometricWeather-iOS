//
//  DailyWindCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/24.
//

import UIKit
import GeometricWeatherBasic

private func toRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180.0
}

// MARK: - cell.

class DailySingleWindCollectionViewCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let dailyIcon = UIImageView(frame: .zero)
    private let histogramView = HistogramView(frame: .zero)
    
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
        ? NSLocalizedString("today", comment: "")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: NSLocalizedString("date_format_short", comment: "")
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
            self.histogramView.histogramValue = (daily.wind?.speed ?? 0.0) / maxWindSpeed
        } else {
            self.histogramView.histogramValue = 0.0
        }
        
        let speedUnit = SettingsManager.shared.speedUnit
        self.histogramView.histogramDescription = speedUnit.formatValueWithUnit(
            daily.wind?.speed ?? 0.0,
            unit: ""
        )
        self.histogramView.histogramColor = getLevelColor(
            daily.wind?.getWindLevel() ?? 1
        )
    }
    
    // MARK: - cell selection.
    
    override var isHighlighted: Bool {
        didSet {
            if (self.isHighlighted) {
                self.contentView.layer.removeAllAnimations()
                self.contentView.alpha = 0.5
            } else {
                self.contentView.layer.removeAllAnimations()
                UIView.animate(
                    withDuration: 0.45,
                    delay: 0.0,
                    options: [.allowUserInteraction, .beginFromCurrentState]
                ) {
                    self.contentView.alpha = 1.0
                } completion: { _ in
                    // do nothing.
                }
            }
        }
    }
}

// MARK: - background.

class DailySingleWindCellBackgroundView: UIView {
    
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
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin + mainTrendIconSize)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        maxWindSpeed: Double
    ) {
        if maxWindSpeed > windSpeedLevel4 {
            self.horizontalLinesView.lowValue = windSpeedLevel4 / maxWindSpeed
            
            self.horizontalLinesView.lowDescription = (
                SettingsManager.shared.speedUnit.formatValueWithUnit(
                    windSpeedLevel4,
                    unit: SettingsManager.shared.speedUnit.key
                ),
                NSLocalizedString("wind_4", comment: "")
            )
        } else {
            self.horizontalLinesView.lowValue = nil
        }
        if maxWindSpeed > windSpeedLevel6 {
            self.horizontalLinesView.highValue = windSpeedLevel6 / maxWindSpeed
            
            self.horizontalLinesView.highDescription = (
                SettingsManager.shared.speedUnit.formatValueWithUnit(
                    windSpeedLevel6,
                    unit: SettingsManager.shared.speedUnit.key
                ),
                NSLocalizedString("wind_6", comment: "")
            )
        } else {
            self.horizontalLinesView.highValue = nil
        }
        
        self.horizontalLinesView.highLineColor = .gray
        self.horizontalLinesView.lowLineColor = .gray
    }
}
