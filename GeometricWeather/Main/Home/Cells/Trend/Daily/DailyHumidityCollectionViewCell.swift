//
//  DailyHumidityCollectionViewCell.swift
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

class DailyHumidityTrendGenerator: MainTrendGenerator, MainTrendGeneratorProtocol {
    
    // data.
    
    private let location: Location
    private let maxHumidity: Double
    
    // properties.
    
    var dispayName: String {
        return getLocalizedText("humidity")
    }
    
    var isValid: Bool {
        return self.maxHumidity > 0
    }
    
    // life cycle.
    
    required init(_ location: Location) {
        self.location = location
        
        var maxHumidity = 0.0
        location.weather?.dailyForecasts.forEach { daily in
            if maxHumidity < daily.humidity ?? 0.0 {
                maxHumidity = daily.humidity ?? 0.0
            }
            if maxHumidity < daily.day.humidity ?? 0.0 {
                maxHumidity = daily.humidity ?? 0.0
            }
            if maxHumidity < daily.night.humidity ?? 0.0 {
                maxHumidity = daily.humidity ?? 0.0
            }
        }
        self.maxHumidity = maxHumidity
    }
    
    // interfaces.
    
    func registerCellClass(to collectionView: UICollectionView) {
        collectionView.register(
            DailyHumidityCollectionViewCell.self,
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
           let cell = cell as? DailyHumidityCollectionViewCell {
            cell.bindData(
                daily: weather.dailyForecasts[indexPath.row],
                weatherCode: weather.current.weatherCode,
                daylight: self.location.isDaylight,
                timezone: self.location.timezone
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

class DailyHumidityCollectionViewCell: MainTrendCollectionViewCell, MainTrendPaddingContainer {
    
    // MARK: - cell subviews.
    
    private let weekLabel = UILabel(frame: .zero)
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
        weatherCode: WeatherCode,
        daylight: Bool,
        timezone: TimeZone
    ) {
        self.weekLabel.text = daily.isToday(timezone: timezone)
        ? getLocalizedText("today")
        : getWeekText(week: daily.getWeek(timezone: timezone))
        
        self.dateLabel.text = daily.getDate(
            format: getLocalizedText("date_format_short")
        )
        
        let humidity = max(
            daily.humidity ?? 0.0,
            max(daily.day.humidity ?? 0.0, daily.night.humidity ?? 0.0)
        )
        
        self.histogramView.highValue = humidity / 100.0
        self.histogramView.lowValue = nil
        
        self.histogramView.highDescription = (
            getPercentTextWithoutUnit(humidity, decimal: 1),
            ""
        )
        self.histogramView.color = UIColor(
            ThemeManager.weatherThemeDelegate.getThemeColor(
                weatherKind: weatherCodeToWeatherKind(code: weatherCode),
                daylight: daylight
            )
        )
    }
}
