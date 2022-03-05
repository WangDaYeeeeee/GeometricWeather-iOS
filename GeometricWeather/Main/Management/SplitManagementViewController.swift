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
        
        self.navigationItem.title = NSLocalizedString("action_manage", comment: "")
        
        self.searchController.searchBar.placeholder = NSLocalizedString(
            "feedback_search_location",
            comment: ""
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
        
        self.tableView.backgroundColor = .clear
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .opaqueSeparator.withAlphaComponent(0.5)
        self.tableView.separatorInset = .zero
        self.tableView.rowHeight = LocationTableViewCell.locationCellHeight
        self.tableView.register(
            LocationTableViewCell.self,
            forCellReuseIdentifier: cellReuseId
        )
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
            
            if strongSelf.param.vm?.addLocation(location: event.location) ?? false {
                strongSelf.searchController.searchBar.text = ""
                strongSelf.searchController.dismiss(animated: true, completion: nil)
                
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.param.vm?.selectableTotalLocations.addObserver(self) { [weak self] newValue in
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
    
    // reset state of view when it become invisible.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.searchController.dismiss(animated: false, completion: nil)
        self.itemList.removeAll()
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
}
