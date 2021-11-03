//
//  MainHourlyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherBasic

private let trendReuseIdentifier = "hourly_trend_cell"
private let hourlyTrendViewHeight = 216.0
private let minutelyTrendViewHeight = 56.0

class MainHourlyCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout {
    
    // MARK: - data.
    
    private var weather: Weather?
    private var timezone: TimeZone?
    private var temperatureRange: TemperatureRange?
    private var source: WeatherSource?
    
    // MARK: - subviews.
    
    private let vstack = UIStackView(frame: .zero)
    
    private let summaryLabel = UILabel(frame: .zero)
    
    private let hourlyTrendGroupView = UIView(frame: .zero)
    private let hourlyBackgroundView = HourlyTrendCellBackgroundView(frame: .zero)
    private let hourlyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    
    private let minutelyTitleVibrancyContainer = UIVisualEffectView(
        effect: UIVibrancyEffect(
            blurEffect: UIBlurEffect(style: .prominent)
        )
    )
    private let minutelyTitle = UILabel(frame: .zero)
    
    private let minutelyView = BeizerPolylineView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        self.cardTitle.text = NSLocalizedString("hourly_overview", comment: "")
        
        self.vstack.axis = .vertical
        self.vstack.alignment = .center
        self.vstack.spacing = 0
        self.cardContainer.contentView.addSubview(self.vstack)
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.vstack.addArrangedSubview(self.summaryLabel)
        
        self.hourlyCollectionView.delegate = self
        self.hourlyCollectionView.dataSource = self
        self.hourlyCollectionView.register(
            HourlyTrendCollectionViewCell.self,
            forCellWithReuseIdentifier: trendReuseIdentifier
        )
        self.hourlyTrendGroupView.addSubview(self.hourlyCollectionView)
        
        self.hourlyBackgroundView.isUserInteractionEnabled = false
        self.hourlyTrendGroupView.addSubview(self.hourlyBackgroundView)
        
        self.vstack.addArrangedSubview(self.hourlyTrendGroupView)
        
        self.minutelyTitle.text = NSLocalizedString(
            "precipitation_overview",
            comment: ""
        )
        self.minutelyTitle.font = titleFont
        self.minutelyTitleVibrancyContainer.contentView.addSubview(self.minutelyTitle)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.vstack.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.summaryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.hourlyTrendGroupView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight + 2 * littleMargin)
        }
        self.hourlyBackgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight)
        }
        self.hourlyCollectionView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight)
        }
        
        self.minutelyTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location) {
        super.bindData(location: location)
        
        self.minutelyTitleVibrancyContainer.removeFromSuperview()
        self.minutelyView.removeFromSuperview()
        
        if let weather = location.weather {
            self.weather = weather
            self.timezone = location.timezone
            
            var maxTemp = weather.yesterday?.daytimeTemperature ?? Int.min
            var minTemp = weather.yesterday?.nighttimeTemperature ?? Int.max
            for hourly in weather.hourlyForecasts {
                if maxTemp < hourly.temperature.temperature {
                    maxTemp = hourly.temperature.temperature
                }
                if minTemp > hourly.temperature.temperature {
                    minTemp = hourly.temperature.temperature
                }
            }
            self.temperatureRange = (minTemp, maxTemp)
            self.source = location.weatherSource

            self.summaryLabel.text = weather.current.hourlyForecast
            
            self.hourlyBackgroundView.bindData(
                weather: weather,
                temperatureRange: self.temperatureRange ?? (0, 0)
            )
            
            self.hourlyCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .left,
                animated: false
            )
            self.hourlyCollectionView.collectionViewLayout.invalidateLayout()
            self.hourlyCollectionView.reloadData()
            
            // minutely.
            
            guard let minutely = weather.minutelyForecast else {
                return
            }
            if minutely.precipitationIntensityInPercentage.count < 2 {
                return
            }
            var allZero = true
            for value in minutely.precipitationIntensityInPercentage {
                if value >= radarPrecipitationIntensityLight {
                    allZero = false
                    break
                }
            }
            if allZero {
                return
            }
            
            self.vstack.addArrangedSubview(self.minutelyTitleVibrancyContainer)
            self.minutelyTitleVibrancyContainer.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(normalMargin)
                make.trailing.equalToSuperview().offset(-normalMargin)
            }
            
            self.minutelyView.polylineColor = ThemeManager.shared.weatherThemeDelegate.getThemeColors(
                weatherKind: weatherCodeToWeatherKind(code: weather.current.weatherCode),
                daylight: ThemeManager.shared.daylight.value,
                lightTheme: self.traitCollection.userInterfaceStyle == .light
            ).daytime
            self.minutelyView.polylineValues = getPrecipitationIntensityInPercentage(
                intensityInRadarStandard: minutely.precipitationIntensityInPercentage
            )
            self.minutelyView.beginTime = formateTime(
                timeIntervalSine1970: minutely.beginTime,
                twelveHour: isTwelveHour()
            )
            self.minutelyView.endTime = formateTime(
                timeIntervalSine1970: minutely.endTime,
                twelveHour: isTwelveHour()
            )
            self.vstack.addArrangedSubview(self.minutelyView)
            self.minutelyView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(minutelyTrendViewHeight)
            }
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.hourlyCollectionView.reloadData()
            
            if let weather = self.weather,
               let range = self.temperatureRange {
                self.hourlyBackgroundView.bindData(weather: weather, temperatureRange: range)
            }
        }
    }
    
    // MARK: - delegates.
    
    // collection view delegate flow layout.
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return self.hourlyCollectionView.cellSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let weather = self.weather,
            let timezone = self.timezone {
            HourlyDialog(
                weather: weather,
                timezone: timezone,
                index: indexPath.row
            ).showSelf()
        }
    }
    
    // data source.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return weather?.hourlyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = self.hourlyCollectionView.dequeueReusableCell(
            withReuseIdentifier: trendReuseIdentifier,
            for: indexPath
        )
        if let weather = self.weather,
            let hourlies = self.weather?.hourlyForecasts {
            
            var histogramType = HourlyHistogramType.none
            if self.source?.hasHourlyPrecipitationProb ?? false {
                histogramType = .precipitationProb
            }
            if self.source?.hasHourlyPrecipitationIntensity ?? false {
                histogramType = .precipitationIntensity
            }
            
            (cell as? HourlyTrendCollectionViewCell)?.bindData(
                prev: indexPath.row == 0 ? nil : hourlies[indexPath.row - 1],
                hourly: hourlies[indexPath.row],
                next: indexPath.row == hourlies.count - 1 ? nil : hourlies[indexPath.row + 1],
                temperatureRange: self.temperatureRange ?? (0, 0),
                weatherCode: weather.current.weatherCode,
                timezone: self.timezone ?? .current,
                histogramType: histogramType
            )
        }
        return cell
    }
}
