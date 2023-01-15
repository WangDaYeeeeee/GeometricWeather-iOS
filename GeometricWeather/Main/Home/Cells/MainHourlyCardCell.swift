//
//  MainHourlyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import SwiftUI

private let hourlyTrendViewHeight = 226.0
private let minutelyTrendViewHeight = 56.0

struct HourlyTrendCellTapAction {
    let index: Int
}

struct HourlyTrendManuallyScrollEvent {
    let targetDayOfYear: Int
}

class MainHourlyCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            MainSelectableTagDelegate {
    
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
    
    // MARK: - data.
    
    private var validTrendGenerators = [MainTrendGeneratorProtocol]()
    
    private let selectionReactor = UISelectionFeedbackGenerator()
    private var isChangingHourlyCollectionViewScrollOffsetManually = false
    private var isDraggingHourlyCollectionView = false
    private var currentScrollDayOfYear = -1
    private var isSyncScrollingEnabled = false
    
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
        
        self.hourlyCollectionView.delegate = self
        self.hourlyCollectionView.dataSource = self
        self.getAllTrendGeneratorTypes().forEach { item in
            item.registerCellClass(to: self.hourlyCollectionView)
        }
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
        self.isSyncScrollingEnabled = SettingsManager.shared.trendSyncEnabled
        
        self.minutelyTitleVibrancyContainer.removeFromSuperview()
        self.minutelyView.removeFromSuperview()
        
        guard let weather = location.weather else {
            return
        }

        self.summaryLabel.text = weather.current.hourlyForecast
        
        let generators = self.ensureTrendGenerators(for: location)
        self.validTrendGenerators = generators.valid
        self.hourlyTagView.tagList = generators.valid.map { item in
            item.dispayName
        }
        
        if self.hourlyCollectionView.numberOfSections != 0
            && self.hourlyCollectionView.numberOfItems(inSection: 0) != 0 {
            self.hourlyCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .left,
                animated: false
            )
            
            if self.isSyncScrollingEnabled {
                self.currentScrollDayOfYear = Calendar.current.ordinality(
                    of: .day,
                    in: .year,
                    for: Date(
                        timeIntervalSince1970: location
                            .weather?
                            .hourlyForecasts
                            .get(0)?
                            .time ?? 0.0
                    )
                ) ?? -1
            }
        }
        
        // minutely.
        
        guard let minutely = weather.minutelyForecast else {
            return
        }
        if minutely.precipitationIntensities.count < 2 {
            return
        }
        var allZero = true
        for value in minutely.precipitationIntensities {
            if value >= precipitationIntensityLight {
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
        
        let color = UIColor(
            ThemeManager.weatherThemeDelegate.getThemeColor(
                weatherKind: weatherCodeToWeatherKind(code: weather.current.weatherCode),
                daylight: location.isDaylight
            )
        )
        self.minutelyView.polylineColor = { _ in color }
        self.minutelyView.baselineColor = color
        self.minutelyView.polylineTintColor = .systemBlue
        
        let maxIntensity = minutely.precipitationIntensities.max { a, b in a < b } ?? precipitationIntensityHeavy
        self.minutelyView.polylineValues = minutely.precipitationIntensities.map { intensity in
            min(1.0, intensity / maxIntensity)
        }
        self.minutelyView.polylineDescriptionMapper = { value in
            let unit = SettingsManager
                .shared
                .precipitationIntensityUnit
            return unit.formatValueWithUnit(value * maxIntensity, unit: getLocalizedText(unit.key))
        }
        
        self.minutelyView.beginTime = formateTime(
            timeIntervalSine1970: minutely.beginTime,
            twelveHour: isTwelveHour()
        )
        self.minutelyView.centerTime = formateTime(
            timeIntervalSine1970: (minutely.beginTime + minutely.endTime) / 2.0,
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
    
    override func willMove(toWindow newWindow: UIWindow?) {
        self.window?
            .windowScene?
            .eventBus
            .unregister(self, for: DailyTrendManuallyScrollEvent.self)
    }
    
    override func didMoveToWindow() {
        self.window?.windowScene?.eventBus.register(
            self,
            for: DailyTrendManuallyScrollEvent.self
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
        let total = self.getAllTrendGeneratorTypes().map { item in
            item.init(location)
        }
        let valid = total.filter { item in
            item.isValid
        }
        return (total: total, valid: valid)
    }
    
    private func getAllTrendGeneratorTypes() -> [MainTrendGeneratorProtocol.Type] {
        return [
            HourlyTemperatureTrendGenerator.self,
            HourlyWindTrendGenerator.self,
            HourlyAirQualityTrendGenerator.self,
            HourlyPrecipitationTrendGenerator.self,
            HourlyHumidityTrendGenerator.self,
            HourlyVisibilityTrendGenerator.self,
        ]
    }
    
    // MARK: - scroll view delegate.
    
    private func respondSynchronizeScrolling(
        for event: DailyTrendManuallyScrollEvent
    ) {
        if self.isDraggingHourlyCollectionView {
            return
        }
        guard let index = self.location?.weather?.hourlyForecasts.firstIndex(where: { item in
            Calendar.current.ordinality(
                of: .day,
                in: .year,
                for: Date(timeIntervalSince1970: item.time)
            ) == event.targetDayOfYear
        }) else {
            return
        }
        
        self.hourlyCollectionView.scrollAligmentlyToScrollBar(
            at: IndexPath(row: index, section: 0),
            animated: true
        )
        self.currentScrollDayOfYear = event.targetDayOfYear
        self.selectionReactor.selectionChanged()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isSyncScrollingEnabled {
            return
        }
        if !self.isChangingHourlyCollectionViewScrollOffsetManually {
            return
        }
        guard let scrollView = scrollView as? MainTrendShaderCollectionView else {
            return
        }
        guard let hourly = self.location?.weather?.hourlyForecasts.get(
            scrollView.highlightIndex
        ) else {
            return
        }
        guard let dayOfYear = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: Date(timeIntervalSince1970: hourly.time)
        ) else {
            return
        }
        
        if self.currentScrollDayOfYear != dayOfYear {
            self.currentScrollDayOfYear = dayOfYear
            
            self.window?.windowScene?.eventBus.post(
                HourlyTrendManuallyScrollEvent(targetDayOfYear: dayOfYear)
            )
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isChangingHourlyCollectionViewScrollOffsetManually = true
        self.isDraggingHourlyCollectionView = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.isChangingHourlyCollectionViewScrollOffsetManually = false
        }
        self.isDraggingHourlyCollectionView = false
        
        if !decelerate && self.isSyncScrollingEnabled {
            self.hourlyCollectionView.scrollAligmentlyToScrollBar(
                at: IndexPath(row: self.hourlyCollectionView.highlightIndex, section: 0),
                animated: true
            )
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isChangingHourlyCollectionViewScrollOffsetManually = false
        
        if !self.isSyncScrollingEnabled
            || scrollView.contentOffset.x <= 0
            || scrollView.contentOffset.x + scrollView.frame.width >= scrollView.contentSize.width {
            return
        }
        self.hourlyCollectionView.scrollAligmentlyToScrollBar(
            at: IndexPath(row: self.hourlyCollectionView.highlightIndex, section: 0),
            animated: true
        )
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
        self.window?.windowScene?.eventBus.post(
            HourlyTrendCellTapAction(index: indexPath.row)
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
            return UIHostingController<HourlyView>(
                rootView: HourlyView(
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
        return self.location?.weather?.hourlyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return self.validTrendGenerators[
            self.hourlyTagView.selectedIndex
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
        self.hourlyCollectionView.collectionViewLayout.invalidateLayout()
        self.hourlyCollectionView.reloadData()
        
        self.validTrendGenerators[
            newSelectedIndex
        ].bindCellBackground(
            to: self.hourlyBackgroundView
        )
    }
    
    func onSelectedRepeatly(currentSelectedIndex: Int) {
        if self.hourlyCollectionView.indexPathsForVisibleItems.first != nil {
            self.hourlyCollectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .start,
                animated: true
            )
        }
        
        if !self.isSyncScrollingEnabled {
            return
        }
        if let hourly = self.location?.weather?.dailyForecasts.first,
           let dayOfYear = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: Date(timeIntervalSince1970: hourly.time)
           ) {
            self.currentScrollDayOfYear = dayOfYear
            self.window?.windowScene?.eventBus.post(
                HourlyTrendManuallyScrollEvent(targetDayOfYear: dayOfYear)
            )
        }
    }
}
