//
//  HomeViewController+UITableView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

private let cellKeyHeader = "header"
private let cellKeyDaily = "daily"
private let cellKeyHourly = "hourly"
private let cellKeyAirQuality = "air_quality"
private let cellKeyAllergen = "allergen"
private let cellKeySunMoon = "sun_moon"
private let cellKeyDetails = "details"

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - interfaces.
    
    @objc func updateTableView() {
        guard let location = self.vmWeakRef.vm?.currentLocation.value else {
            return
        }
        
        if self.tableView.numberOfSections != 0
            && self.tableView.numberOfRows(inSection: 0) != 0 {
            self.tableView.scrollToRow(
                at: IndexPath(row: 0, section: 0),
                at: .top,
                animated: false
            )
        }
        self.tableView(
            self.tableView,
            didEndDisplayingHeaderView: self.headerCache,
            forSection: 0
        )
        
        self.cellKeyList = self.prepareCellKeyList(location: location)
        self.cellAnimationHelper.reset()
        self.tableView.reloadData()
        self.bindDataForHeaderAndCells(location)
        
        self.tableView(
            self.tableView,
            willDisplayHeaderView: self.headerCache,
            forSection: 0
        )
    }
    
    func prepareCellCache() -> Dictionary<String, MainTableViewCell> {
        let dict = [
            cellKeyDaily: MainDailyCardCell(style: .default, reuseIdentifier: cellKeyDaily),
            cellKeyHourly: MainHourlyCardCell(style: .default, reuseIdentifier: cellKeyHourly),
            cellKeyAirQuality: MainAirQualityCardCell(style: .default, reuseIdentifier: cellKeyAirQuality),
            cellKeyAllergen: MainAllergenCardCell(style: .default, reuseIdentifier: cellKeyAllergen),
            cellKeySunMoon: MainSunMoonCardCell(style: .default, reuseIdentifier: cellKeySunMoon),
            cellKeyDetails: MainDetailsCardCell(style: .default, reuseIdentifier: cellKeyDetails),
        ]
        return dict
    }
    
    func prepareCellKeyList(location: Location) -> [String] {
        if let weather = location.weather {
            var keyList = [String]()
            
            if weather.dailyForecasts.count > 0 {
                keyList.append(cellKeyDaily)
            }
            if weather.hourlyForecasts.count > 0 {
                keyList.append(cellKeyHourly)
            }
            if weather.current.airQuality.aqiLevel != nil
                && weather.current.airQuality.aqiIndex != nil
                && (weather.current.airQuality.pm25 != nil
                    || weather.current.airQuality.pm10 != nil
                    || weather.current.airQuality.so2 != nil
                    || weather.current.airQuality.no2 != nil
                    || weather.current.airQuality.o3 != nil
                    || weather.current.airQuality.co != nil) {
                keyList.append(cellKeyAirQuality)
            }
            if weather.dailyForecasts.count > 0
                && weather.dailyForecasts[0].pollen.isValid() {
                keyList.append(cellKeyAllergen)
            }
            if weather.dailyForecasts.count > 0
                && weather.dailyForecasts[0].sun.isValid() {
                keyList.append(cellKeySunMoon)
            }
            keyList.append(cellKeyDetails)
            
            return keyList
        }
        
        return [String]()
    }
    
    func hideHeaderAndCells() {
        self.headerCache.alpha = 0.0
        
        for cell in self.cellCache.values {
            cell.alpha = 0.0
        }
    }
    
    func bindDataForHeaderAndCells(_ location: Location) {
        self.headerCache.bindData(location: location)
        
        for cell in self.cellCache.values {
            cell.bindData(location: location)
        }
        
        self.cellHeightCache.removeAll()
    }
    
    // MARK: - delegate.
    
    // header.
    
    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        self.cellAnimationHelper.tableView(
            tableView,
            willDisplayHeaderView: view,
            forSection: section
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplayingHeaderView view: UIView,
        forSection section: Int
    ) {
        self.cellAnimationHelper.tableView(
            tableView,
            didEndDisplayingHeaderView: view,
            forSection: section
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        return self.headerCache
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return ThemeManager.shared.weatherThemeDelegate.getHeaderHeight(
            tableView.frame.height
        ) - self.view.safeAreaInsets.top
    }
    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForHeaderInSection section: Int
    ) -> CGFloat {
        if let cache = self.cellHeightCache[cellKeyHeader] {
            if cache > 0 {
                return cache
            }
        }
        
        let height = ThemeManager.shared.weatherThemeDelegate.getHeaderHeight(
            tableView.frame.height
        ) - self.view.safeAreaInsets.top
        self.cellHeightCache[cellKeyHeader] = height
        return height
    }
    
    // cells.
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        self.cellAnimationHelper.tableView(
            tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        self.cellAnimationHelper.tableView(
            tableView,
            didEndDisplaying: cell,
            forRowAt: indexPath
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if let cache = self.cellHeightCache[
            cellKeyList[indexPath.row]
        ] {
            if cache > 0 {
                return cache
            }
        }
        
        let height = cellCache[
            cellKeyList[indexPath.row]
        ]!.contentView.systemLayoutSizeFitting(
            CGSize(
                width: getTabletAdaptiveWidth(
                    maxWidth: tableView.frame.width
                ),
                height: 0.0
            )
        ).height
        self.cellHeightCache[
            cellKeyList[indexPath.row]
        ] = height
        return height
    }
    
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if let cache = self.cellHeightCache[
            cellKeyList[indexPath.row]
        ] {
            if cache > 0 {
                return cache
            }
        }
        
        let height = cellCache[
            cellKeyList[indexPath.row]
        ]!.contentView.systemLayoutSizeFitting(
            CGSize(
                width: getTabletAdaptiveWidth(
                    maxWidth: tableView.frame.width
                ),
                height: 0.0
            )
        ).height
        self.cellHeightCache[
            cellKeyList[indexPath.row]
        ] = height
        return height
    }
    
    // scroll.
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerHeight = ThemeManager.shared.weatherThemeDelegate.getHeaderHeight(
            scrollView.frame.height
        ) - scrollView.safeAreaInsets.top
        
        let blur = scrollView.contentOffset.y > headerHeight - 256.0
        && headerHeight > 0
        
        if self.blurNavigationBar != blur {
            self.blurNavigationBar = blur
        }
    }
    
    // MARK: - data source.
    
    // headers.
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return "header"
    }
    
    // cells.
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return cellKeyList.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        return cellCache[
            cellKeyList[indexPath.row]
        ]!
    }
}
