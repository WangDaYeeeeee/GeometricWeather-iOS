//
//  ManagementViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/27.
//

import UIKit
import AudioToolbox
import GeometricWeatherBasic

private let cellReuseId = "ManagementTableViewCell"

class SplitManagementViewController: BaseManagementController,
                                        UISearchControllerDelegate,
                                        UISearchResultsUpdating,
                                        UISearchBarDelegate {
    
    // subviews.
    
    private lazy var searchController = {
        return UISearchController(searchResultsController: self.resultController)
    }()
    private let resultController = SearchResultController(param: true)
    
    // inner data.
    
    override var transparentCell: Bool {
        get {
            return false
        }
    }
    
    // MARK: - life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.navigationItem.title = getLocalizedText("action_manage")
        
        self.searchController.searchBar.placeholder = getLocalizedText(
            "feedback_search_location"
        )
        self.searchController.searchBar.setImage(
            UIImage(systemName: "location.circle"),
            for: .bookmark,
            state: .normal
        )
        self.searchController.automaticallyShowsScopeBar = true
        self.searchController.automaticallyShowsCancelButton = true
        self.searchController.automaticallyShowsSearchResultsController = false
        self.searchController.delegate = self
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.navigationItem.searchController = self.searchController
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        EventBus.shared.register(self, for: HideKeyboardEvent.self) { [weak self] event in
            if (self?.resultController.locationCount ?? 0) == 0 && (
                self?.searchController.searchBar.text?.isEmpty ?? true
            ) {
                self?.searchController.dismiss(animated: true, completion: nil)
            } else {
                self?.searchController.searchBar.endEditing(true)
            }
        }
        EventBus.shared.register(self, for: AddLocationEvent.self) { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.param.addLocation(location: event.location) {
                strongSelf.searchController.searchBar.text = ""
                strongSelf.searchController.dismiss(animated: true, completion: nil)
                
                ToastHelper.showToastMessage(
                    getLocalizedText("feedback_collect_succeed"),
                    inWindowOfView: strongSelf.view
                )
            } else {
                ToastHelper.showToastMessage(
                    getLocalizedText("feedback_collect_failed"),
                    inWindowOfView: strongSelf.view
                )
            }
        }
        
        self.param.selectableTotalLocations.addObserver(self) { [weak self] newValue in
            guard let strongSelf = self else {
                return
            }
            
            let _ = strongSelf.updateLocationList(newValue)
            
            let showBookmarkButton = !strongSelf.itemList.contains { item in
                item.location.currentPosition
            }
            if strongSelf.searchController.searchBar.showsBookmarkButton != showBookmarkButton {
                strongSelf.searchController.searchBar.showsBookmarkButton = showBookmarkButton
            }
        }
    }
    
    // MARK: - search controller delegate.
    
    func willPresentSearchController(_ searchController: UISearchController) {
        self.resultController.requesting.value = false
        self.resultController.resetList()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = false
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = false
        
        self.resultController.requesting.value = false
        self.resultController.resetList()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if text == "" {
                return
            }
            
            self.searchController.searchBar.endEditing(true)
            self.resultController.search(text)
        }
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.text = ""

        if self.param.addLocation(
            location: Location.buildLocal(
                weatherSource: SettingsManager.shared.weatherSource
            )
        ) {
            ToastHelper.showToastMessage(
                getLocalizedText("feedback_collect_succeed"),
                inWindowOfView: self.view
            )
        }
    }
}
