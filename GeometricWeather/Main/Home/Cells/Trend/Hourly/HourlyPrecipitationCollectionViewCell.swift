//
//  HourlyPrecipitationCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/18.
//

import UIKit
import GeometricWeatherBasic

class HourlyPrecipitationCollectionViewCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
    private let trendView = HistogramView(frame: .zero)
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.backgroundColor = .clear
        
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .label
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.contentView.addSubview(self.hourLabel)
        
        self.dateLabel.font = miniCaptionFont
        self.dateLabel.textColor = .secondaryLabel
        self.dateLabel.textAlignment = .center
        self.dateLabel.numberOfLines = 1
        self.contentView.addSubview(self.dateLabel)
        
        self.hourlyIcon.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.hourlyIcon)
        
        self.trendView.paddingBottom = normalMargin
        self.contentView.addSubview(self.trendView)
                
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.hourlyIcon.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.hourlyIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.trendView.snp.makeConstraints { make in
            make.top.equalTo(self.hourlyIcon.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(
        hourly: Hourly,
        timezone: TimeZone,
        histogramType: HourlyPrecipitationHistogramType
    ) {
        self.hourLabel.text = getHourText(
            hour: hourly.getHour(
                isTwelveHour(),
                timezone: timezone
            )
        )
        
        self.dateLabel.text = hourly.formatDate(
            format: NSLocalizedString("date_format_short", comment: "")
        )
        
        self.hourlyIcon.image = UIImage.getWeatherIcon(
            weatherCode: hourly.weatherCode,
            daylight: hourly.daylight
        )?.scaleToSize(
            CGSize(
                width: mainTrendIconSize,
                height: mainTrendIconSize
            )
        )
        
        switch histogramType {
        case .precipitationProb:
            let precipitationProb = hourly.precipitationProbability ?? 0.0
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
            
        case .precipitationIntensity:
            let unit = SettingsManager.shared.precipitationIntensityUnit
            let precipitationIntensity = hourly.precipitationIntensity ?? 0.0
            if precipitationIntensity > 0 {
                self.trendView.highValue = min(
                    precipitationIntensity / radarPrecipitationIntensityHeavy,
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
