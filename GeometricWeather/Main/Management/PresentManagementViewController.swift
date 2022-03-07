//
//  ManagementViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/27.
//

import UIKit
import GeometricWeatherBasic

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
    
    private let blurBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .prominent)
    )
    private let searchBar = UISearchBar(frame: .zero)
    private let searchViewController = SearchResultController(param: false)
    
    // MARK: - life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        self.view.addSubview(self.blurBackground)
        
        self.searchBar.placeholder = NSLocalizedString(
            "feedback_search_location",
            comment: ""
        )
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
        
        EventBus.shared.register(self, for: HideKeyboardEvent.self) { [weak self] event in
            if (self?.searchViewController.locationCount ?? 0) == 0 && (
                self?.searchBar.text?.isEmpty ?? true
            ) {
                self?.searching.value = false
            } else {
                self?.searchBar.endEditing(true)
            }
        }
        EventBus.shared.register(self, for: AddLocationEvent.self) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.param.vm?.addLocation(location: event.location) ?? false {
                strongSelf.searchBar.text = ""
                strongSelf.searching.value = false
                
                ToastHelper.showToastMessage(
                    NSLocalizedString("feedback_collect_succeed", comment: ""),
                    inWindowOfView: strongSelf.view
                )
            } else {
                ToastHelper.showToastMessage(
                    NSLocalizedString("feedback_collect_failed", comment: ""),
                    inWindowOfView: strongSelf.view
                )
            }
        }
        
        self.param.vm?.selectableTotalLocations.addObserver(
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
    
    // reset state of view when it become invisible.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.searching.value = false
    }
    
    // MARK: - interfaces.
    
    override func updateLocationList(
        _ newList: SelectableLocationArray
    ) -> BaseManagementController.UpdateLocationListResult {
        
        let result = super.updateLocationList(newList)
        
        switch result {
        case .new:
            self.staggeredHelper.reset()
            break
        case .deleted:
            self.staggeredHelper.changeLastIndexPath(
                IndexPath(
                    row: self.itemList.count - 1,
                    section: 0
                )
            )
            break
        default:
            break
        }
        
        return result
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
        
        if self.param.vm?.addLocation(
            location: Location.buildLocal(
                weatherSource: SettingsManager.shared.weatherSource
            )
        ) ?? false {
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_collect_succeed", comment: ""),
                inWindowOfView: self.view
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
        self.staggeredHelper.tableView(
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
        self.staggeredHelper.tableView(
            tableView,
            didEndDisplaying: cell,
            forRowAt: indexPath
        )
    }
}
