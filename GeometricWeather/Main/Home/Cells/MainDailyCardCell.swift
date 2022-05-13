//
//  MainDailyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import SwiftUI

private let dailyTrendViewHeight = 286

enum DailyTag: String {
    
    case temperature = "daily_temperature"
    case wind = "daily_wind"
    case aqi = "daily_aqi"
    case uv = "daily_uv"
    case precipitationIntensity = "daily_precipitation_intensity"
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
    
    private let summaryLabel = UILabel(frame: .zero)
    
    private let dailyTagView = MainSelectableTagView(frame: .zero)
    
    private let dailyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    private var dailyBackgroundView = MainTrendBackgroundView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.cardTitle.text = getLocalizedText("daily_overview")
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.cardContainer.contentView.addSubview(self.summaryLabel)
        
        self.dailyTagView.tagDelegate = self
        self.cardContainer.contentView.addSubview(self.dailyTagView)
        
        self.registerCells(collectionView: self.dailyCollectionView)
        self.dailyCollectionView.delegate = self
        self.dailyCollectionView.dataSource = self
        self.cardContainer.contentView.addSubview(self.dailyCollectionView)
        
        self.dailyBackgroundView.isUserInteractionEnabled = false
        self.cardContainer.contentView.addSubview(self.dailyBackgroundView)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
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
            
            self.summaryLabel.text = weather.current.dailyForecast
            
            self.tagList = self.buildTagList(weather: weather)
            var titles = [String]()
            for tagPair in self.tagList {
                titles.append(tagPair.title)
            }
            self.dailyTagView.tagList = titles
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.dailyCollectionView.reloadData()
        }
    }
    
    @objc private func onDeviceOrientationChanged() {
        if !self.dailyCollectionView.indexPathsForVisibleItems.isEmpty {
            self.dailyCollectionView.reloadData()
        }
    }
    
    // MARK: - collection view delegate.
    
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
        self.window?.windowScene?.eventBus.post(
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
            return UIHostingController<DailyView>(
                rootView: DailyView(
                    weather: weather,
                    index: indexPath.row,
                    timezone: timezone
                )
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
        return buildCell(
            collectionView: self.dailyCollectionView,
            currentTag: self.currentTag,
            indexPath: indexPath,
            weather: self.weather,
            source: self.source,
            timezone: self.timezone ?? .current,
            temperatureRange: self.temperatureRange ?? 0...0,
            maxWindSpeed: self.maxWindSpeed ?? 0,
            maxAqiIndex: self.maxAqiIndex ?? 0,
            maxUVIndex: self.maxUVIndex ?? 0
        )
    }
    
    // MARK: - selectable tag view delegate.
        
    func getSelectedColor() -> UIColor {
        return .systemBlue
    }
    
    func getUnselectedColor() -> UIColor {
        return UIColor(
            ThemeManager.weatherThemeDelegate.getThemeColor(
                weatherKind: weatherCodeToWeatherKind(
                    code: self.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.window?.windowScene?.themeManager.daylight.value ?? true
            )
        ).withAlphaComponent(0.33)
    }
    
    func onSelectedChanged(newSelectedIndex: Int) {
        self.currentTag = self.tagList[newSelectedIndex].tag
        
        self.dailyCollectionView.scrollToItem(
            at: IndexPath(row: 0, section: 0),
            at: .left,
            animated: false
        )
        self.dailyCollectionView.collectionViewLayout.invalidateLayout()
        self.dailyCollectionView.reloadData()
        
        self.bindTrendBackground(
            trendBackgroundView: self.dailyBackgroundView,
            currentTag: self.currentTag,
            weather: self.weather,
            source: self.source,
            timezone: self.timezone ?? .current,
            temperatureRange: self.temperatureRange ?? 0...0,
            maxWindSpeed: self.maxWindSpeed ?? 0,
            maxAqiIndex: self.maxAqiIndex ?? 0,
            maxUVIndex: self.maxUVIndex ?? 0
        )
    }
}
