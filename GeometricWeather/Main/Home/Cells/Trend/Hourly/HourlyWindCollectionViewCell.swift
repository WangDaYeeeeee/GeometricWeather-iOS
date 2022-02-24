//
//  HourlyWindCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/24.
//

import UIKit
import GeometricWeatherBasic

// MARK: - cell.

class HourlyWindCollectionViewCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
    private let histogramView = HistogramView(frame: .zero)
    
    // MARK: - cell life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .label
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.contentView.addSubview(self.hourLabel)
        
        self.hourlyIcon.contentMode = .center
        self.contentView.addSubview(self.hourlyIcon)
        
        self.contentView.addSubview(self.histogramView)
        
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.hourlyIcon.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(littleMargin)
            make.width.equalTo(mainTrendIconSize)
            make.width.lessThanOrEqualToSuperview()
            make.height.equalTo(self.hourlyIcon.snp.width)
            make.centerX.equalToSuperview()
        }
        self.histogramView.snp.makeConstraints { make in
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
        maxWindSpeed: Double,
        timezone: TimeZone
    ) {
        self.hourLabel.text = getHourText(
            hour: hourly.getHour(
                isTwelveHour(),
                timezone: timezone
            )
        )
        
        if !(hourly.wind?.degree.noDirection ?? true) {
            self.hourlyIcon.image = UIImage(
                systemName: "arrow.up"
            )?.withTintColor(
                .label
            ).scaleToSize(
                CGSize(
                    width: mainWindIconSize,
                    height: mainWindIconSize
                )
            )
            self.hourlyIcon.transform = CGAffineTransform(
                rotationAngle: hourly.wind?.degree.degree ?? 0.0
            )
        } else {
            self.hourlyIcon.image = UIImage(
                named: "arrow.up.and.down.and.arrow.left.and.right"
            )?.withTintColor(
                .label
            ).scaleToSize(
                CGSize(
                    width: mainWindIconSize,
                    height: mainWindIconSize
                )
            )
            self.hourlyIcon.transform = CGAffineTransform(rotationAngle: 0.0)
        }
        
        if maxWindSpeed > 0 {
            self.histogramView.histogramValue = (hourly.wind?.speed ?? 0.0) / maxWindSpeed
        } else {
            self.histogramView.histogramValue = 0.0
        }
        
        let speedUnit = SettingsManager.shared.speedUnit
        self.histogramView.histogramDescription = speedUnit.formatValueWithUnit(
            hourly.wind?.speed ?? 0.0,
            unit: NSLocalizedString(speedUnit.key, comment: "")
        )
        self.histogramView.histogramColor = getLevelColor(
            hourly.wind?.getWindLevel() ?? 1
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

class HourlyWindCellBackgroundView: UIView {
    
    // MARK: - background subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    
    private let horizontalLinesView = HorizontalLinesBackgroundView(frame: .zero)
    
    // MARK: - background life cycle.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.hourLabel.text = "A"
        self.hourLabel.font = bodyFont
        self.hourLabel.textColor = .clear
        self.hourLabel.textAlignment = .center
        self.hourLabel.numberOfLines = 1
        self.addSubview(self.hourLabel)
        
        self.addSubview(self.horizontalLinesView)
        
        self.hourLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(mainTrendInnerMargin)
            make.leading.equalToSuperview().offset(mainTrendInnerMargin)
            make.trailing.equalToSuperview().offset(-mainTrendInnerMargin)
        }
        self.horizontalLinesView.snp.makeConstraints { make in
            make.top.equalTo(self.hourLabel.snp.bottom).offset(littleMargin + mainTrendIconSize)
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

