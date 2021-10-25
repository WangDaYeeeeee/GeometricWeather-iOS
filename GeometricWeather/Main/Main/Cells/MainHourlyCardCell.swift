//
//  MainHourlyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherBasic

private let trendReuseIdentifier = "hourly_trend_cell"
private let hourlyTrendViewHeight = 256

class MainHourlyCardCell: MainTableViewCell,
                            UICollectionViewDataSource {
    
    // MARK: - data.
    
    private var weather: Weather?
    private var timezone: TimeZone?
    private var temperatureRange: TemperatureRange?
    private var source: WeatherSource?
    
    // MARK: - subviews.
    
    private let summaryLabel = UILabel(frame: .zero)
    
    private let hourlyBackgroundView = HourlyTrendCellBackgroundView(frame: .zero)
    private let hourlyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        self.cardTitle.text = NSLocalizedString("hourly_overview", comment: "")
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.cardContainer.contentView.addSubview(self.summaryLabel)
        
        self.hourlyCollectionView.dataSource = self
        self.hourlyCollectionView.register(
            HourlyTrendCollectionViewCell.self,
            forCellWithReuseIdentifier: trendReuseIdentifier
        )
        self.hourlyCollectionView.itemSelected = { [weak self] index in
            if let weather = self?.weather,
                let timezone = self?.timezone,
                let view = UIApplication.shared.keyWindowInCurrentScene {
                HourlyDialog(
                    weather: weather,
                    timezone: timezone,
                    index: index.row
                ).showOn(view)
            }
        }
        self.cardContainer.contentView.addSubview(self.hourlyCollectionView)
        
        self.hourlyBackgroundView.isUserInteractionEnabled = false
        self.cardContainer.contentView.addSubview(self.hourlyBackgroundView)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.hourlyBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.summaryLabel.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight)
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
        self.hourlyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.hourlyBackgroundView.snp.top)
            make.leading.equalTo(self.hourlyBackgroundView.snp.leading)
            make.trailing.equalTo(self.hourlyBackgroundView.snp.trailing)
            make.bottom.equalTo(self.hourlyBackgroundView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location) {
        super.bindData(location: location)
        
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
        return CGSize(
            width: collectionView.frame.width / CGFloat(getTrenItemDisplayCount()),
            height: collectionView.frame.height
        )
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
