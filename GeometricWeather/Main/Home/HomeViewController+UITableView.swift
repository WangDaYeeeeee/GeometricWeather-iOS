//
//  HomeViewController+UITableView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

private let cellKeyHeader = "header"
private let cellKeyDaily = MainCard.daily.key
private let cellKeyHourly = MainCard.hourly.key
private let cellKeyAirQuality = MainCard.airQuality.key
private let cellKeyAllergen = MainCard.allergen.key
private let cellKeySunMoon = MainCard.sunMoon.key
private let cellKeyDetails = MainCard.details.key
private let cellKeyFooter = "footer"

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - interfaces.
    
    @objc func updateTableView() {
        let location = self.vm.currentLocation.value
        
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
    
    func prepareCellCache() -> Dictionary<String, AbstractMainItem> {
        var dict = Dictionary<String, AbstractMainItem>()
        
        dict[cellKeyDaily] = MainDailyCardCell(style: .default, reuseIdentifier: cellKeyDaily)
        dict[cellKeyHourly] = MainHourlyCardCell(style: .default, reuseIdentifier: cellKeyHourly)
        dict[cellKeyAirQuality] = MainAirQualityCardCell(style: .default, reuseIdentifier: cellKeyAirQuality)
        dict[cellKeyAllergen] = MainAllergenCardCell(style: .default, reuseIdentifier: cellKeyAllergen)
        dict[cellKeySunMoon] = MainSunMoonCardCell(style: .default, reuseIdentifier: cellKeySunMoon)
        dict[cellKeyDetails] = MainDetailsCardCell(style: .default, reuseIdentifier: cellKeyDetails)
        dict[cellKeyFooter] = MainFooterCell(style: .default, reuseIdentifier: cellKeyFooter)
        
        return dict
    }
    
    func prepareCellKeyList(location: Location) -> [String] {
        guard let weather = location.weather else {
            return [String]()
        }
        
        var keys = SettingsManager.shared.mainCards.filter { card in
            return card.validator(weather)
        }.map { card in
            return card.key
        }
        keys.append(cellKeyFooter)
        return keys
    }
    
    func hideHeaderAndCells() {
        self.headerCache.alpha = 0.0
        
        for cell in self.cellCache.values {
            (cell as? UIView)?.alpha = 0.0
        }
    }
    
    func bindDataForHeaderAndCells(_ location: Location) {
        self.headerCache.bindData(location: location, timeBar: nil)
        
        for item in self.cellCache {
            item.value.bindData(
                location: location,
                timeBar: item.key == self.cellKeyList.get(0) ? self.timeBarCache : nil
            )
        }
        
        self.cellHeightCache.removeAll()
    }
    
    func rotateHeaderAndCells() {
        self.cellHeightCache.removeAll()
        self.tableView.reloadData()
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
        
        let height = (cellCache[
            cellKeyList[indexPath.row]
        ] as? UITableViewCell)?.contentView.systemLayoutSizeFitting(
            CGSize(
                width: getTabletAdaptiveWidth(
                    maxWidth: tableView.frame.width
                ),
                height: 0.0
            )
        ).height ?? 0.0
        
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
        
        let height = (cellCache[
            cellKeyList[indexPath.row]
        ] as? UITableViewCell)?.contentView.systemLayoutSizeFitting(
            CGSize(
                width: getTabletAdaptiveWidth(
                    maxWidth: tableView.frame.width
                ),
                height: 0.0
            )
        ).height ?? 0.0
        
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
        
        if scrollView.contentOffset.y <= headerHeight
            || self.weatherViewController.scrollOffset <= headerHeight {
            self.weatherViewController.scrollOffset = scrollView.contentOffset.y
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
        ] as! UITableViewCell
    }
}
