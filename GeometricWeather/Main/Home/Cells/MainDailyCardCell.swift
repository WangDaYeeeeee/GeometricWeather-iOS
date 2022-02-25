//
//  MainDailyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

private let dailyTrendViewHeight = 286

private enum DailyTag: String {
    
    case temperature = "daily_temperature"
    case wind = "daily_wind"
    case aqi = "daily_aqi"
    case uv = "daily_uv"
}

struct DailyTrendCellTapAction {
    
    let index: Int
}

class MainDailyCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            MainSelectableTagDelegate {
    
    // MARK: - data.
    
    private var weather: Weather?
    private var timezone: TimeZone?
    
    private var temperatureRange: ClosedRange<Int>?
    private var maxWindSpeed: Double?
    private var maxAqiIndex: Int?
    private var maxUVIndex: Int?
    
    private var source: WeatherSource?
    
    private var tagList = [(tag: DailyTag, title: String)]()
    private var currentTag = DailyTag.temperature
    
    // MARK: - subviews.
    
    private let timeBar = MainTimeBarView()
    private let summaryLabel = UILabel(frame: .zero)
    
    private let dailyTagView = MainSelectableTagView(frame: .zero)
    
    private let dailyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    private var dailyBackgroundView = DailyTrendCellBackgroundView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardContainer.contentView.addSubview(self.timeBar)
        
        self.cardTitle.text = NSLocalizedString("daily_overview", comment: "")
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.cardContainer.contentView.addSubview(self.summaryLabel)
        
        self.dailyTagView.tagDelegate = self
        self.cardContainer.contentView.addSubview(self.dailyTagView)
        
        self.dailyCollectionView.delegate = self
        self.dailyCollectionView.dataSource = self
        self.dailyCollectionView.register(
            DailyTrendCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.temperature.rawValue
        )
        self.dailyCollectionView.register(
            DailySingleWindCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.wind.rawValue
        )
        self.dailyCollectionView.register(
            DailyAirQualityCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.aqi.rawValue
        )
        self.dailyCollectionView.register(
            DailyUVCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyTag.uv.rawValue
        )
        self.cardContainer.contentView.addSubview(self.dailyCollectionView)
        
        self.dailyBackgroundView.isUserInteractionEnabled = false
        self.cardContainer.contentView.addSubview(self.dailyBackgroundView)
        
        self.timeBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalTo(self.timeBar.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.dailyTagView.snp.makeConstraints { make in
            make.top.equalTo(self.summaryLabel.snp.bottom).offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        self.dailyBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.dailyTagView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(dailyTrendViewHeight)
            make.bottom.equalToSuperview().offset(-normalMargin)
        }
        self.dailyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.dailyBackgroundView.snp.top)
            make.leading.equalTo(self.dailyBackgroundView.snp.leading)
            make.trailing.equalTo(self.dailyBackgroundView.snp.trailing)
            make.bottom.equalTo(self.dailyBackgroundView.snp.bottom)
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
            var maxWind = 0.0
            var maxAqi = 0
            var maxUV = 0
            for daily in weather.dailyForecasts {
                if maxTemp < daily.day.temperature.temperature {
                    maxTemp = daily.day.temperature.temperature
                }
                if minTemp > daily.night.temperature.temperature {
                    minTemp = daily.night.temperature.temperature
                }
                if maxWind < daily.wind?.speed ?? 0.0 {
                    maxWind = daily.wind?.speed ?? 0.0
                }
                if maxAqi < daily.airQuality.aqiIndex ?? 0 {
                    maxAqi = daily.airQuality.aqiIndex ?? 0
                }
                if maxUV < daily.uv.index ?? 0 {
                    maxUV = daily.uv.index ?? 0
                }
            }
            self.temperatureRange = minTemp...maxTemp
            self.maxWindSpeed = maxWind
            self.maxAqiIndex = maxAqi
            self.maxUVIndex = maxUV
            
            self.source = location.weatherSource
            
            self.timeBar.register(
                weather: weather,
                andTimezone: location.timezone
            )
            
            self.summaryLabel.text = weather.current.dailyForecast
            
            self.buildTagList()
            
            if let weather = self.weather,
               let range = self.temperatureRange {
                self.dailyBackgroundView.bindData(weather: weather, temperatureRange: range)
            }
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.dailyCollectionView.reloadData()
            
            if let weather = self.weather,
               let range = self.temperatureRange {
                self.dailyBackgroundView.bindData(weather: weather, temperatureRange: range)
            }
        }
    }
    
    // MARK: - ui.
    
    private func buildTagList() {
        var tags = [(DailyTag.temperature, NSLocalizedString("temperature", comment: ""))]
        
        // wind.
        for daily in (self.weather?.dailyForecasts ?? []) {
            if daily.wind != nil {
                tags.append(
                    (DailyTag.wind, NSLocalizedString("wind", comment: ""))
                )
                break
            }
        }
        
        // aqi.
        for daily in (self.weather?.dailyForecasts ?? []) {
            if daily.airQuality.isValid() {
                tags.append(
                    (DailyTag.aqi, NSLocalizedString("air_quality", comment: ""))
                )
                break
            }
        }
        
        // uv.
        for daily in (self.weather?.dailyForecasts ?? []) {
            if daily.uv.isValid() {
                tags.append(
                    (DailyTag.uv, NSLocalizedString("uv_index", comment: ""))
                )
                break
            }
        }
        
        self.tagList = tags
        
        var titles = [String]()
        for tagPair in self.tagList {
            titles.append(tagPair.title)
        }
        
        self.dailyTagView.tagList = titles
    }
    
    // MARK: - delegates.
    
    // collection view delegate flow layout.
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return self.dailyCollectionView.cellSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        EventBus.shared.post(
            DailyTrendCellTapAction(index: indexPath.row)
        )
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
            return DailyPageController(
                weather: weather,
                index: indexPath.row,
                timezone: timezone
            )
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
        return weather?.dailyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = self.dailyCollectionView.dequeueReusableCell(
            withReuseIdentifier: self.currentTag.rawValue,
            for: indexPath
        )
        
        switch self.currentTag {
        case .temperature:
            if let weather = self.weather,
                let dailies = self.weather?.dailyForecasts {
                
                var histogramType = DailyHistogramType.none
                if self.source?.hasDailyPrecipitationProb ?? false {
                    histogramType = .precipitationProb
                }
                if self.source?.hasDailyPrecipitationTotal ?? false {
                    histogramType = .precipitationTotal
                }
                if self.source?.hasDailyPrecipitationIntensity ?? false {
                    histogramType = .precipitationIntensity
                }
                
                (cell as? DailyTrendCollectionViewCell)?.bindData(
                    prev: indexPath.row == 0 ? nil : dailies[indexPath.row - 1],
                    daily: dailies[indexPath.row],
                    next: indexPath.row == dailies.count - 1 ? nil : dailies[indexPath.row + 1],
                    temperatureRange: self.temperatureRange ?? 0...0,
                    weatherCode: weather.current.weatherCode,
                    timezone: self.timezone ?? .current,
                    histogramType: histogramType
                )
            }
        case .wind:
            if let dailies = self.weather?.dailyForecasts {
                (cell as? DailySingleWindCollectionViewCell)?.bindData(
                    daily: dailies[indexPath.row],
                    maxWindSpeed: self.maxWindSpeed ?? 0.0,
                    timezone: self.timezone ?? .current
                )
            }
        case .aqi:
            if let dailies = self.weather?.dailyForecasts {
                (cell as? DailyAirQualityCollectionViewCell)?.bindData(
                    daily: dailies[indexPath.row],
                    maxAqiIndex: self.maxAqiIndex ?? 0,
                    timezone: self.timezone ?? .current
                )
            }
        case .uv:
            if let dailies = self.weather?.dailyForecasts {
                (cell as? DailyUVCollectionViewCell)?.bindData(
                    daily: dailies[indexPath.row],
                    maxAqiIndex: self.maxUVIndex ?? 0,
                    timezone: self.timezone ?? .current
                )
            }
        }
        
        return cell
    }
    
    // selectable tag view.
    
    func getSelectedColor() -> UIColor {
        return .systemBlue
    }
    
    func getUnselectedColor() -> UIColor {
        return ThemeManager.shared.weatherThemeDelegate.getThemeColors(
            weatherKind: weatherCodeToWeatherKind(
                code: self.weather?.current.weatherCode ?? .clear
            ),
            daylight: ThemeManager.shared.daylight.value
        ).main.withAlphaComponent(0.33)
    }
    
    func onSelectedChanged(newSelectedIndex: Int) {
        self.currentTag = self.tagList[newSelectedIndex].tag
        self.dailyBackgroundView.isHidden = self.tagList[newSelectedIndex].tag != .temperature
        
        self.dailyCollectionView.scrollToItem(
            at: IndexPath(row: 0, section: 0),
            at: .left,
            animated: false
        )
        self.dailyCollectionView.collectionViewLayout.invalidateLayout()
        self.dailyCollectionView.reloadData()
    }
}
