//
//  DailyAirQualityCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/24.
//

import UIKit
import GeometricWeatherBasic

// MARK: - cell.

class DailyAirQualityCollectionViewCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
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
        
        self.histogramView.paddingBottom = normalMargin
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
        self.histogramView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(
                littleMargin + mainTrendIconSize
            )
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
        maxAqiIndex: Int,
        timezone: TimeZone
    ) {
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? NSLocalizedString("today", comment: "")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: NSLocalizedString("date_format_short", comment: "")
        )
        
        if maxAqiIndex > 0 {
            self.histogramView.highValue = Double(
                (daily.airQuality.aqiIndex ?? 0)
            ) / Double(
                maxAqiIndex
            )
        } else {
            self.histogramView.highValue = 0.0
        }
        self.histogramView.lowValue = nil
        
        self.histogramView.highDescription = (
            daily.airQuality.aqiIndex?.description ?? "",
            ""
        )
        self.histogramView.color = getLevelColor(
            daily.airQuality.getAqiLevel()
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

class DailyAirQualityCellBackgroundView: UIView {
    
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
        maxAqiIndex: Int
    ) {
        if maxAqiIndex > aqiIndexLevel2 {
            self.horizontalLinesView.lowValue = Double(aqiIndexLevel2) / Double(maxAqiIndex)
            
            self.horizontalLinesView.lowDescription = (
                aqiIndexLevel2.description,
                NSLocalizedString("aqi_2", comment: "")
            )
        } else {
            self.horizontalLinesView.lowValue = nil
        }
        if maxAqiIndex > aqiIndexLevel5 {
            self.horizontalLinesView.highValue = Double(aqiIndexLevel5) / Double(maxAqiIndex)
            
            self.horizontalLinesView.highDescription = (
                aqiIndexLevel5.description,
                NSLocalizedString("aqi_5", comment: "")
            )
        } else {
            self.horizontalLinesView.highValue = nil
        }
        
        self.horizontalLinesView.highLineColor = .gray
        self.horizontalLinesView.lowLineColor = .gray
    }
}
