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

// MARK: - generator.

class DailyWindTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
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
        location.weather?.dailyForecasts.forEach { daily in
            if maxWind < daily.wind?.speed ?? 0.0 {
                maxWind = daily.wind?.speed ?? 0.0
            }
            if maxWind < daily.day.wind?.speed ?? 0.0 {
                maxWind = daily.day.wind?.speed ?? 0.0
            }
            if maxWind < daily.night.wind?.speed ?? 0.0 {
                maxWind = daily.night.wind?.speed ?? 0.0
            }
        }
        self.maxWindSpeed = maxWind
    }
    
    // interfaces.
    
    func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            DailySingleWindCollectionViewCell.self,
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
           let cell = cell as? DailySingleWindCollectionViewCell {
            cell.bindData(
                daily: weather.dailyForecasts[indexPath.row],
                maxWindSpeed: self.maxWindSpeed,
                timezone: self.location.timezone
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
        
        let wind = daily.day.wind != nil && daily.night.wind != nil
        ? (
            daily.day.wind?.speed ?? 0.0 > daily.night.wind?.speed ?? 0.0
            ? daily.day.wind
            : daily.night.wind
        ) : daily.wind
        
        if wind?.degree.noDirection == false {
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
                rotationAngle: toRadians(wind?.degree.degree ?? 0.0)
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
            self.histogramView.highValue = (wind?.speed ?? 0.0) / maxWindSpeed
        } else {
            self.histogramView.highValue = 0.0
        }
        self.histogramView.lowValue = nil
        
        let speedUnit = SettingsManager.shared.speedUnit
        self.histogramView.highDescription = (
            speedUnit.formatValueWithUnit(
                wind?.speed ?? 0.0,
                unit: ""
            ),
            ""
        )
        self.histogramView.color = getLevelColor(
            wind?.getWindLevel() ?? 1
        )
    }
}
