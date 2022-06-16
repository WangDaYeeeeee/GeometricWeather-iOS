//
//  HourlyVisibilityCollectionViewCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/6/15.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - generator.

class HourlyVisibilityTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private let maxVisibility: Double

    // properties.
    
    var dispayName: String {
        return getLocalizedText("visibility")
    }
    
    var isValid: Bool {
        return self.maxVisibility > 0
    }
    
    // life cycle.
    
    required init(_ location: Location) {
        self.location = location
        
        var maxVisibility = 0.0
        location.weather?.hourlyForecasts.forEach { hourly in
            if maxVisibility < hourly.visibility ?? 0.0 {
                maxVisibility = hourly.visibility ?? 0.0
            }
        }
        self.maxVisibility = maxVisibility
    }
    
    // interfaces.
    
    func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            HourlyVisibilityCollectionViewCell.self,
            forCellWithReuseIdentifier: self.key
        )
    }
    
    func bindCellData(
        at indexPath: IndexPath,
        to collectionView: UICollectionView
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: self.key,
            for: indexPath
        )
        
        if let weather = self.location.weather,
           let cell = cell as? HourlyVisibilityCollectionViewCell {
            
            var useAccentColorForDate = indexPath.row == 0
            if weather.hourlyForecasts[
                indexPath.row
            ].getHour(
                false,
                timezone: self.location.timezone
            ) == 0 {
                useAccentColorForDate = true
            }
            
            cell.bindData(
                hourly: weather.hourlyForecasts[indexPath.row],
                timezone: self.location.timezone,
                maxVisibility: self.maxVisibility,
                useAccentColorForDate: useAccentColorForDate
            )
            cell.trendPaddingTop = naturalTrendPaddingTop
            cell.trendPaddingBottom = naturalTrendPaddingBottom
        }
        
        return cell
    }
    
    func bindCellBackground(to trendBackgroundView: MainTrendBackgroundView) {
        trendBackgroundView.bindData(
            highLines: [],
            lowLines: [],
            lineColor: .clear,
            paddingTop: naturalTrendPaddingTop + naturalBackgroundIconPadding,
            paddingBottom: naturalTrendPaddingBottom
        )
    }
}

// MARK: - cell.

class HourlyVisibilityCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let hourLabel = UILabel(frame: .zero)
    private let dateLabel = UILabel(frame: .zero)
    
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
        hourly: Hourly,
        timezone: TimeZone,
        maxVisibility: Double,
        useAccentColorForDate: Bool
    ) {
        self.hourLabel.text = getHourText(
            hour: hourly.getHour(
                isTwelveHour(),
                timezone: timezone
            )
        )
        
        self.dateLabel.text = hourly.formatDate(
            format: getLocalizedText("date_format_short")
        )
        self.dateLabel.textColor = useAccentColorForDate
        ? .secondaryLabel
        : .tertiaryLabel
        
        let visibility = hourly.visibility ?? 0.0
        
        self.histogramView.highValue = visibility / max(maxVisibility, 1.0)
        self.histogramView.lowValue = nil
        
        self.histogramView.highDescription = (
            SettingsManager.shared.distanceUnit.formatValueWithUnit(visibility, unit: ""),
            ""
        )
        self.histogramView.color = getLevelColor(
            getVisibilityLevel(visibility)
        )
    }
}
