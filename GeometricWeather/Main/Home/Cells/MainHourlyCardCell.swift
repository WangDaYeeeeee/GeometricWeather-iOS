//
//  MainHourlyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherBasic

private let hourlyTrendViewHeight = 226.0
private let minutelyTrendViewHeight = 56.0

enum HourlyTag: String {
    
    case temperature = "hourly_temperature"
    case wind = "hourly_wind"
    case precipitationIntensity = "hourly_precipitation_intensity"
}

class MainHourlyCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            MainSelectableTagDelegate {
    
    // MARK: - data.
    
    private var weather: Weather?
    private var timezone: TimeZone?
    
    private var temperatureRange: ClosedRange<Int>?
    private var maxWindSpeed: Double?
    
    private var source: WeatherSource?
    
    private var tagList = [(tag: HourlyTag, title: String)]()
    private var currentTag = HourlyTag.temperature
    
    // MARK: - subviews.
    
    private let vstack = UIStackView(frame: .zero)
    
    private let summaryLabel = UILabel(frame: .zero)
    
    private let tagPaddingTop = UIView(frame: .zero)
    private let hourlyTagView = MainSelectableTagView(frame: .zero)
    
    private let hourlyTrendGroupView = UIView(frame: .zero)
    private let hourlyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    private let hourlyBackgroundView = MainTrendBackgroundView(frame: .zero)
    
    private let minutelyTitleVibrancyContainer = UIVisualEffectView(
        effect: UIVibrancyEffect(
            blurEffect: UIBlurEffect(style: .prominent)
        )
    )
    private let minutelyTitle = UILabel(frame: .zero)
    
    private let minutelyView = HistogramPolylineView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        self.cardTitle.text = getLocalizedText("hourly_overview")
        
        self.vstack.axis = .vertical
        self.vstack.alignment = .center
        self.vstack.spacing = 0
        self.cardContainer.contentView.addSubview(self.vstack)
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.vstack.addArrangedSubview(self.summaryLabel)
        
        self.vstack.addArrangedSubview(self.tagPaddingTop)
        
        self.hourlyTagView.tagDelegate = self
        self.vstack.addArrangedSubview(self.hourlyTagView)
        
        self.registerCells(collectionView: self.hourlyCollectionView)
        self.hourlyCollectionView.delegate = self
        self.hourlyCollectionView.dataSource = self
        self.hourlyTrendGroupView.addSubview(self.hourlyCollectionView)
        
        self.hourlyBackgroundView.isUserInteractionEnabled = false
        self.hourlyTrendGroupView.addSubview(self.hourlyBackgroundView)
        
        self.vstack.addArrangedSubview(self.hourlyTrendGroupView)
        
        self.minutelyTitle.text = getLocalizedText("precipitation_overview")
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
        self.tagPaddingTop.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(littleMargin)
        }
        self.hourlyTagView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onDeviceOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        self.minutelyTitleVibrancyContainer.removeFromSuperview()
        self.minutelyView.removeFromSuperview()
        
        if let weather = location.weather {
            self.weather = weather
            self.timezone = location.timezone
            
            var maxTemp = weather.yesterday?.daytimeTemperature ?? Int.min
            var minTemp = weather.yesterday?.nighttimeTemperature ?? Int.max
            var maxWind = 0.0
            for hourly in weather.hourlyForecasts {
                if maxTemp < hourly.temperature.temperature {
                    maxTemp = hourly.temperature.temperature
                }
                if minTemp > hourly.temperature.temperature {
                    minTemp = hourly.temperature.temperature
                }
                if maxWind < hourly.wind?.speed ?? 0.0 {
                    maxWind = hourly.wind?.speed ?? 0.0
                }
            }
            self.temperatureRange = minTemp...maxTemp
            self.maxWindSpeed = maxWind
            self.source = location.weatherSource

            self.summaryLabel.text = weather.current.hourlyForecast
            
            self.tagList = self.buildTagList(weather: weather)
            var titles = [String]()
            for tagPair in self.tagList {
                titles.append(tagPair.title)
            }
            self.hourlyTagView.tagList = titles
            
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
            
            self.minutelyView.polylineColor = ThemeManager.shared.weatherThemeDelegate.getThemeColor(
                weatherKind: weatherCodeToWeatherKind(code: weather.current.weatherCode),
                daylight: ThemeManager.shared.daylight.value
            )
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
        }
    }
    
    @objc private func onDeviceOrientationChanged() {
        if !self.hourlyCollectionView.indexPathsForVisibleItems.isEmpty {
            self.hourlyCollectionView.reloadData()
        }
    }
        
    // MARK: - collection view delegate.
    
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
            ).showSelf(
                inWindowOfView: self
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let weather = self.weather,
            let timezone = self.timezone
        else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: NSNumber(value: indexPath.row)
        ) {
            let vc = HourlyViewController(
                param: (weather, timezone, indexPath.row)
            )
            vc.measureAndSetPreferredContentSize()
            return vc
        } actionProvider: { _ in
            return nil
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let row = (configuration.identifier as? NSNumber)?.intValue else {
            return nil
        }
        guard let cell = collectionView.cellForItem(
            at: IndexPath(row: row, section: 0)
        ) else {
            return nil
        }
        
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        
        return UITargetedPreview(view: cell, parameters: params)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return self.collectionView(
            collectionView,
            previewForHighlightingContextMenuWithConfiguration: configuration
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
        return self.buildCell(
            collectionView: self.hourlyCollectionView,
            currentTag: self.currentTag,
            indexPath: indexPath,
            weather: self.weather,
            source: self.source,
            timezone: self.timezone ?? .current,
            temperatureRange: self.temperatureRange ?? 0...0,
            maxWindSpeed: self.maxWindSpeed ?? 0
        )
    }
    
    // MARK: - selectable tag view delegate.
    
    func getSelectedColor() -> UIColor {
        return .systemBlue
    }
    
    func getUnselectedColor() -> UIColor {
        return ThemeManager.shared.weatherThemeDelegate.getThemeColor(
            weatherKind: weatherCodeToWeatherKind(
                code: self.weather?.current.weatherCode ?? .clear
            ),
            daylight: ThemeManager.shared.daylight.value
        ).withAlphaComponent(0.33)
    }
    
    func onSelectedChanged(newSelectedIndex: Int) {
        self.currentTag = self.tagList[newSelectedIndex].tag
        
        self.hourlyCollectionView.scrollToItem(
            at: IndexPath(row: 0, section: 0),
            at: .left,
            animated: false
        )
        self.hourlyCollectionView.collectionViewLayout.invalidateLayout()
        self.hourlyCollectionView.reloadData()
        
        self.bindTrendBackground(
            trendBackgroundView: self.hourlyBackgroundView,
            currentTag: self.currentTag,
            weather: self.weather,
            source: self.source,
            timezone: self.timezone ?? .current,
            temperatureRange: self.temperatureRange ?? 0...0,
            maxWindSpeed: self.maxWindSpeed ?? 0
        )
    }
}
