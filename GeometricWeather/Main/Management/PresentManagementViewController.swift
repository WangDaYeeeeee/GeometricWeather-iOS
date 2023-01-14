//
//  ManagementViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/27.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private let cellReuseId = "ManagementTableViewCell"

class PresentManagementViewController: BaseManagementController,
                                        UISearchBarDelegate {
    
    
    // MARK: - properties.
    
    // inner data.
    
    private let staggeredHelper = StaggeredCellAnimationHelper(
        initOffset: CGSize(width: 0.0, height: 256.0)
    )
    
    private let searching = EqualtableLiveData(false)
        
    // subviews.
    
    private let blurBackground = UIVisualEffectView(effect: nil)
    private let searchBar = UISearchBar(frame: .zero)
    private lazy var searchViewController = {
        return SearchResultController(param: false, in: self.scene)
    }()
    
    // MARK: - life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        self.view.addSubview(self.blurBackground)
        
        self.searchBar.placeholder = getLocalizedText("feedback_search_location")
        self.searchBar.setImage(
            UIImage(systemName: "location.circle"),
            for: .bookmark,
            state: .normal
        )
        self.searchBar.delegate = self
        self.blurBackground.contentView.addSubview(self.searchBar)
        
        self.blurBackground.contentView.addSubview(self.tableView)
        
        self.addChild(self.searchViewController)
        self.searchViewController.view.alpha = 0.0
        self.blurBackground.contentView.addSubview(self.searchViewController.view)
        
        self.blurBackground.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        self.searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(56.0)
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.searchViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
        
        self.scene?.eventBus.register(
            self,
            for: HideKeyboardEvent.self
        ) { [weak self] event in
            if (self?.searchViewController.locationCount ?? 0) == 0 && (
                self?.searchBar.text?.isEmpty ?? true
            ) {
                self?.searching.value = false
            } else {
                self?.searchBar.endEditing(true)
            }
        }
        
        self.scene?.eventBus.register(
            self,
            for: AddLocationEvent.self
        ) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.param.addLocation(location: event.location) {
                strongSelf.searchBar.text = ""
                strongSelf.searching.value = false
                
                ToastHelper.showToastMessage(
                    getLocalizedText("feedback_collect_succeed"),
                    inWindowOf: strongSelf.view
                )
            } else {
                ToastHelper.showToastMessage(
                    getLocalizedText("feedback_collect_failed"),
                    inWindowOf: strongSelf.view
                )
            }
        }
        
        self.param.selectableTotalLocations.addObserver(
            self
        ) { [weak self] newValue in
            guard let strongSelf = self else {
                return
            }
            
            let _ = strongSelf.updateLocationList(newValue)
            
            let showBookmarkButton = !strongSelf.itemList.contains { item in
                item.location.currentPosition
            }
            if strongSelf.searchBar.showsBookmarkButton != showBookmarkButton {
                strongSelf.searchBar.showsBookmarkButton = showBookmarkButton
            }
        }
        self.searching.addObserver(
            self
        ) { [weak self] newValue in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.searchBar.setShowsCancelButton(
                newValue,
                animated: true
            )
            if !newValue {
                strongSelf.searchBar.text = ""
                strongSelf.view.endEditing(true)
                
                strongSelf.searchViewController.requesting.value = false
                strongSelf.searchViewController.resetList()
            }
            
            UIView.animate(withDuration: 0.3) {
                strongSelf.searchViewController.view.alpha = newValue ? 1.0 : 0.0
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.blurBackground.effect = UIBlurEffect(style: .systemChromeMaterial)
        }
    }
    
    // reset state of view when it become invisible.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searching.value = false
    }
    
    // MARK: - ui.
    
    override func dismiss() {
        super.dismiss()
        self.dismiss(animated: true)
    }
    
    override func updateLocationList(_ newList: SelectableLocationArray) {
        let oldCount = self.itemList.count
        if self.itemList.isEmpty {
            self.staggeredHelper.reset()
        }
        
        super.updateLocationList(newList)
        
        if self.itemList.count < oldCount {
            self.staggeredHelper.lastIndexPath = IndexPath(
                row: self.itemList.count - 1,
                section: 0
            )
        }
    }
    
    // MARK: - search bar delegate.
        
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searching.value = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if text == "" {
                return
            }
            
            self.searchViewController.search(text)
            self.view.endEditing(true)
        }
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searching.value = false
        
        if self.param.addLocation(
            location: Location.buildLocal(
                weatherSource: SettingsManager.shared.weatherSource
            )
        ) {
            ToastHelper.showToastMessage(
                getLocalizedText("feedback_collect_succeed"),
                inWindowOf: self.view
            )
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searching.value = false
    }
    
    // MARK: - staggerd animation.
    
    // staggerd.
        
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if self.staggeredHelper.compareIndexPaths(
            left: self.staggeredHelper.lastIndexPath,
            right: indexPath
        ) < 0 {
            cell.alpha = 0
            
            DispatchQueue.main.async {
                self.staggeredHelper.tableView(
                    tableView,
                    willDisplay: cell,
                    forRowAt: indexPath
                )
            }
        } else {
            self.staggeredHelper.tableView(
                tableView,
                willDisplay: cell,
                forRowAt: indexPath
            )
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        self.staggeredHelper.tableView(
            tableView,
            didEndDisplaying: cell,
            forRowAt: indexPath
        )
    }
}
