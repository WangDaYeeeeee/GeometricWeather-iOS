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

struct DailyTrendCellTapAction {
    let index: Int
}

struct DailyTrendManuallyScrollEvent {
    let targetDayOfYear: Int
}

class MainDailyCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            MainSelectableTagDelegate {
    
    // MARK: - subviews.
    
    private let summaryLabel = UILabel(frame: .zero)
    
    private let dailyTagView = MainSelectableTagView(frame: .zero)
    
    private let dailyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    private var dailyBackgroundView = MainTrendBackgroundView(frame: .zero)
    
    // MARK: - data.
    
    private var validTrendGenerators = [MainTrendGeneratorProtocol]()
    
    private var isChangingDailyCollectionViewScrollOffsetManually = false
    private var isDraggingDailyCollectionView = false
    private var currentScrollDayOfYear = -1
    
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
            make.top.equalTo(self.dailyTagView.snp.bottom).offset(littleMargin)
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
        let firstBind = self.location == nil
        super.bindData(location: location, timeBar: timeBar)
        
        guard let weather = location.weather else {
            return
        }
        
        self.summaryLabel.text = weather.current.dailyForecast
        
        let generators = self.ensureTrendGenerators(for: location)
        if firstBind {
            generators.total.forEach { item in
                item.registerCellClass(to: self.dailyCollectionView)
            }
        }
        
        self.validTrendGenerators = generators.valid
        self.dailyTagView.tagList = generators.valid.map { item in
            item.dispayName
        }
        
        if self.dailyCollectionView.numberOfSections != 0
            && self.dailyCollectionView.numberOfItems(inSection: 0) != 0 {
            self.dailyCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .start,
                animated: false
            )
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
    
    override func willMove(toWindow newWindow: UIWindow?) {
        self.window?
            .windowScene?
            .eventBus
            .unregister(self, for: HourlyTrendManuallyScrollEvent.self)
    }
    
    override func didMoveToWindow() {
        self.window?.windowScene?.eventBus.register(
            self,
            for: HourlyTrendManuallyScrollEvent.self
        ) { [weak self] event in
            self?.respondSynchronizeScrolling(for: event)
        }
    }
    
    // MARK: - generators.
    
    private func ensureTrendGenerators(
        for location: Location
    ) -> (
        total: [MainTrendGeneratorProtocol],
        valid: [MainTrendGeneratorProtocol]
    ) {
        let total: [MainTrendGeneratorProtocol] = [
            DailyTemperatureTrendGenerator(location),
            DailyWindTrendGenerator(location),
            DailyAirQualityTrendGenerator(location),
            DailyUVTrendGenerator(location),
            DailyPrecipitationTrendGenerator(location),
            DailyHumidityTrendGenerator(location),
            DailyVisibilityTrendGenerator(location),
        ]
        let valid = total.filter { item in
            item.isValid
        }
        return (total: total, valid: valid)
    }
    
    // MARK: - scroll view delegate.
    
    private func respondSynchronizeScrolling(
        for event: HourlyTrendManuallyScrollEvent
    ) {
        if self.isDraggingDailyCollectionView {
            return
        }
        guard let index = self.location?.weather?.dailyForecasts.firstIndex(where: { item in
            Calendar.current.ordinality(
                of: .day,
                in: .year,
                for: Date(timeIntervalSince1970: item.time)
            ) == event.targetDayOfYear
        }) else {
            return
        }
        
        self.dailyCollectionView.scrollAligmentlyToScrollBar(
            at: IndexPath(row: index, section: 0),
            animated: true
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !SettingsManager.shared.trendSyncEnabled {
            return
        }
        if !self.isChangingDailyCollectionViewScrollOffsetManually {
            return
        }
        guard let scrollView = scrollView as? MainTrendShaderCollectionView else {
            return
        }
        guard let daily = self.location?.weather?.dailyForecasts.get(
            scrollView.highlightIndex
        ) else {
            return
        }
        guard let dayOfYear = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: Date(timeIntervalSince1970: daily.time)
        ) else {
            return
        }
        
        if self.currentScrollDayOfYear != dayOfYear {
            self.currentScrollDayOfYear = dayOfYear
            
            self.window?.windowScene?.eventBus.post(
                DailyTrendManuallyScrollEvent(targetDayOfYear: dayOfYear)
            )
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isChangingDailyCollectionViewScrollOffsetManually = true
        self.isDraggingDailyCollectionView = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.isChangingDailyCollectionViewScrollOffsetManually = false
        }
        self.isDraggingDailyCollectionView = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isChangingDailyCollectionViewScrollOffsetManually = false
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
            let weather = self.location?.weather,
            let timezone = self.location?.timezone
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
        return self.location?.weather?.dailyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return self.validTrendGenerators[
            self.dailyTagView.selectedIndex
        ].bindCellData(
            at: indexPath,
            to: collectionView
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
                    code: self.location?.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.location?.isDaylight ?? true
            )
        ).withAlphaComponent(0.33)
    }
    
    func onSelectedChanged(newSelectedIndex: Int) {
        self.dailyCollectionView.collectionViewLayout.invalidateLayout()
        self.dailyCollectionView.reloadData()
        
        self.validTrendGenerators[
            newSelectedIndex
        ].bindCellBackground(
            to: self.dailyBackgroundView
        )
    }
    
    func onSelectedRepeatly(currentSelectedIndex: Int) {
        if self.dailyCollectionView.indexPathsForVisibleItems.first != nil {
            self.dailyCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .start,
                animated: true
            )
        }
        if let daily = self.location?.weather?.dailyForecasts.first,
           let dayOfYear = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: Date(timeIntervalSince1970: daily.time)
           ) {
            self.currentScrollDayOfYear = dayOfYear
            self.window?.windowScene?.eventBus.post(
                DailyTrendManuallyScrollEvent(targetDayOfYear: dayOfYear)
            )
        }
    }
}
