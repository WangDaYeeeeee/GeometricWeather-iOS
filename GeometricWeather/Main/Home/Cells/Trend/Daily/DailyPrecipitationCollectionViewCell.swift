//
//  DailyPrecipitationCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/18.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

class DailyPrecipitationCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
    private let daytimeIcon = UIImageView(frame: .zero)
    private let nighttimeIcon = UIImageView(frame: .zero)
    
    private let trendView = HistogramView(frame: .zero)
    
    // MARK: - inner data.
        
    var trendPaddingTop: CGFloat {
        get {
            return self.trendView.paddingTop
        }
        set {
            self.trendView.paddingTop = newValue
        }
    }
    
    var trendPaddingBottom: CGFloat {
        get {
            return self.trendView.paddingBottom
        }
        set {
            self.trendView.paddingBottom = newValue
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
        
        self.daytimeIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.daytimeIcon)
        
        self.nighttimeIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.nighttimeIcon)
        
        self.contentView.addSubview(self.trendView)
        
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
        self.daytimeIcon.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.daytimeIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.nighttimeIcon.snp.makeConstraints { make in
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.daytimeIcon.snp.width)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.trendView.snp.makeConstraints { make in
            make.top.equalTo(self.daytimeIcon.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.nighttimeIcon.snp.top)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        daily: Daily,
        timezone: TimeZone,
        histogramType: DailyPrecipitationHistogramType
    ) {
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? getLocalizedText("today")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: getLocalizedText("date_format_short")
        )
        
        self.daytimeIcon.image = UIImage.getWeatherIcon(
            weatherCode: daily.day.weatherCode,
            daylight: true
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        self.nighttimeIcon.image = UIImage.getWeatherIcon(
            weatherCode: daily.night.weatherCode,
            daylight: false
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        
        switch histogramType {
        case .precipitationProb:
            let precipitationProb = max(
                daily.day.precipitationProbability ?? 0.0,
                daily.night.precipitationProbability ?? 0.0,
                daily.precipitationProbability ?? 0.0
            )
            if precipitationProb > 0 {
                self.trendView.highValue = min(precipitationProb / 100.0, 1.0)
                
                self.trendView.highDescription = (
                    getPercentTextWithoutUnit(
                        precipitationProb,
                        decimal: 0
                    ),
                    "%"
                )
                self.trendView.lowDescription = nil
            } else {
                self.trendView.highValue = nil
                
                self.trendView.highDescription = nil
                self.trendView.lowDescription = (
                    getPercentTextWithoutUnit(
                        precipitationProb,
                        decimal: 0
                    ),
                    "%"
                )
            }
            self.trendView.lowValue = nil
            
            self.trendView.color = getLevelColor(
                getPrecipitationProbLevel(precipitationProb)
            )
            break
            
        case .precipitationTotal(let maxPrecipitationTotal):
            let unit = SettingsManager.shared.precipitationUnit
            let precipitationTotal = max(
                daily.day.precipitationTotal ?? 0.0,
                daily.night.precipitationTotal ?? 0.0,
                daily.precipitationTotal ?? 0.0
            )
            if precipitationTotal > 0 {
                self.trendView.highValue = min(
                    precipitationTotal / maxPrecipitationTotal,
                    1.0
                )
                
                self.trendView.highDescription = (
                    unit.formatValueWithUnit(
                        precipitationTotal,
                        unit: ""
                    ),
                    ""
                )
                self.trendView.lowDescription = nil
            } else {
                self.trendView.highValue = nil
                
                self.trendView.highDescription = nil
                self.trendView.lowDescription = (
                    unit.formatValueWithUnit(
                        precipitationTotal,
                        unit: ""
                    ),
                    ""
                )
            }
            self.trendView.lowValue = nil
            
            self.trendView.color = getLevelColor(
                getDailyPrecipitationLevel(precipitationTotal)
            )
            break
            
        case .precipitationIntensity(let maxPrecipitationIntensity):
            let unit = SettingsManager.shared.precipitationIntensityUnit
            let precipitationIntensity = max(
                daily.day.precipitationIntensity ?? 0.0,
                daily.night.precipitationIntensity ?? 0.0,
                daily.precipitationIntensity ?? 0.0
            )
            if precipitationIntensity > 0 {
                self.trendView.highValue = min(
                    precipitationIntensity / maxPrecipitationIntensity,
                    1.0
                )
                
                self.trendView.highDescription = (
                    unit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: ""
                    ),
                    ""
                )
                self.trendView.lowDescription = nil
            } else {
                self.trendView.highValue = nil
                
                self.trendView.highDescription = nil
                self.trendView.lowDescription = (
                    unit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: ""
                    ),
                    ""
                )
            }
            self.trendView.lowValue = nil
            
            self.trendView.color = getLevelColor(
                getPrecipitationIntensityLevel(precipitationIntensity)
            )
            break
            
        case .none:
            self.trendView.highValue = nil
        }
    }
}
