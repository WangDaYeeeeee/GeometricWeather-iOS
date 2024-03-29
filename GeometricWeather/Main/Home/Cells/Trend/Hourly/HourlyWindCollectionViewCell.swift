//
//  HourlyWindCollectionViewCell.swift
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
import SwiftUI

// MARK: - generator.

class HourlyWindTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private var maxWindSpeed: Double
    
    // properties.
    
    var dispayName: String {
        return getLocalizedText("wind")
    }
    
    var isValid: Bool {
        return self.maxWindSpeed > 0.0
    }
    
    // life cycle.
    
    required init(_ location: Location) {
        self.location = location
        
        var maxWind = 0.0
        location.weather?.hourlyForecasts.forEach { hourly in
            if maxWind < hourly.wind?.speed ?? 0.0 {
                maxWind = hourly.wind?.speed ?? 0.0
            }
        }
        self.maxWindSpeed = maxWind
    }
    
    // interfaces.
    
    static func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            HourlyWindCollectionViewCell.self,
            forCellWithReuseIdentifier: Self.key
        )
    }
    
    func bindCellData(
        at indexPath: IndexPath,
        to collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.key,
            for: indexPath
        )
        
        if let weather = self.location.weather,
           let cell = cell as? HourlyWindCollectionViewCell {
            
             var useAccentColorForDate = indexPath.row == 0
             if weather
                .hourlyForecasts[indexPath.row]
                .getHour(inTwelveHourFormat: false) == 0 {
                 useAccentColorForDate = true
             }
            
            cell.bindData(
                hourly: weather.hourlyForecasts[indexPath.row],
                maxWindSpeed: self.maxWindSpeed,
                timezone: self.location.timezone,
                useAccentColorForDate: useAccentColorForDate
            )
            cell.trendPaddingTop = naturalTrendPaddingTop
            cell.trendPaddingBottom = naturalTrendPaddingBottom
        }
        
        return cell
    }
    
    func bindCellBackground(to trendBackgroundView: MainTrendBackgroundView) {
        let highLines = [
            (speed: windSpeedLevel3, desc: getLocalizedText("wind_3")),
            (speed: windSpeedLevel5, desc: getLocalizedText("wind_5")),
            (speed: windSpeedLevel7, desc: getLocalizedText("wind_7")),
            (speed: windSpeedLevel10, desc: getLocalizedText("wind_10")),
        ].filter { item in
            item.speed <= self.maxWindSpeed
        }.map { item in
            HorizontalLine(
                value: item.speed / self.maxWindSpeed,
                leadingDescription: SettingsManager.shared.speedUnit.formatValue(item.speed),
                trailingDescription: item.desc
            )
        }
        trendBackgroundView.bindData(
            highLines: highLines,
            lowLines: [],
            lineColor: mainTrendBackgroundLineColor,
            paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
            paddingBottom: naturalTrendPaddingBottom
        )
    }
}

// MARK: - cell.

private func toRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180.0
}

class HourlyWindCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    private let hourlyIcon = UIImageView(frame: .zero)
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
        
        self.hourlyIcon.contentMode = .center
        self.contentView.addSubview(self.hourlyIcon)
        
        self.contentView.addSubview(self.histogramView)
        
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
        timezone: TimeZone,
        useAccentColorForDate: Bool
    ) {
        self.hourLabel.text = getHourText(hourly)
        
        self.dateLabel.text = hourly.formatDate(
            format: getLocalizedText("date_format_short")
        )
        self.dateLabel.textColor = useAccentColorForDate
        ? .label
        : .tertiaryLabel
        self.dateLabel.font = useAccentColorForDate
        ? .systemFont(ofSize: miniCaptionFont.pointSize, weight: .bold)
        : miniCaptionFont
        
        if !(hourly.wind?.degree.noDirection ?? true) {
            self.hourlyIcon.image = UIImage(
                systemName: "arrow.down"
            )?.withTintColor(
                .label
            ).scaleToSize(
                CGSize(
                    width: mainWindIconSize,
                    height: mainWindIconSize
                )
            )
            self.hourlyIcon.transform = CGAffineTransform(
                rotationAngle: toRadians(hourly.wind?.degree.degree ?? 0.0)
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
            self.histogramView.highValue = (hourly.wind?.speed ?? 0.0) / maxWindSpeed
        } else {
            self.histogramView.highValue = 0.0
        }
        self.histogramView.lowValue = nil
        
        let speedUnit = SettingsManager.shared.speedUnit
        self.histogramView.highDescription = (
            speedUnit.formatValueWithUnit(
                hourly.wind?.speed ?? 0.0,
                unit: ""
            ),
            ""
        )
        self.histogramView.color = getLevelColor(
            hourly.wind?.getWindLevel() ?? 1
        )
    }
}
