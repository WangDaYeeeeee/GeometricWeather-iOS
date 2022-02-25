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

class SplitManagementViewController: GeoViewController<MainViewModelWeakRef>,
                                        UISearchControllerDelegate,
                                        UISearchResultsUpdating,
                                        UISearchBarDelegate,
                                        JXMovableCellTableViewDataSource,
                                        JXMovableCellTableViewDelegate {
    
    
    // MARK: - properties.
    
    // inner data.
    
    var itemList = [LocationItem]()
    
    var moveBeginIndex: IndexPath?
    
    // subviews.
    
    private lazy var searchController = {
        return UISearchController(searchResultsController: self.resultController)
    }()
    private let tableView = JXMovableCellTableView(frame: .zero, style: .plain)
    private let resultController = SearchResultController(param: true)
    
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
        self.tableView.rowHeight = locationCellHeight
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
            if self?.param.vm?.addLocation(location: event.location) ?? false {
                self?.searchController.searchBar.text = ""
                self?.searchController.dismiss(animated: true, completion: nil)
                
                ToastHelper.showToastMessage(
                    NSLocalizedString("feedback_collect_succeed", comment: "")
                )
            } else {
                ToastHelper.showToastMessage(
                    NSLocalizedString("feedback_collect_failed", comment: "")
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
            
            strongSelf.updateLocationList(newValue)
            
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
    
    // MARK: - interfaces.
    
    private func updateLocationList(_ newList: SelectableLocationArray) {
        
        // new.
        if self.itemList.isEmpty {
            self.generateItemList(newList, withoutSelectedState: false)
            self.tableView.reloadData()
            return
        }
        
        let itemCountChanged = self.itemList.count != newList.locations.count
        
        if self.itemList.count < newList.locations.count {
            // add.
            let oldCount = self.itemList.count
            let newCount = newList.locations.count
            
            self.generateItemList(newList, withoutSelectedState: true)
            
            var indexPaths = [IndexPath]()
            for i in oldCount ..< newCount {
                indexPaths.append(
                    IndexPath(row: i, section: 0)
                )
            }
            
            self.tableView.insertRows(
                at: indexPaths,
                with: .none
            )
        } else if self.itemList.count > newList.locations.count {
            // delete.
            
            var indexPaths = [IndexPath]()
            
            var oldIndex = 0
            var newIndex = 0
            while oldIndex < self.itemList.count
                    && newIndex < newList.locations.count {
                
                if self.itemList[oldIndex].location.formattedId
                    == newList.locations[newIndex].formattedId {
                    oldIndex += 1
                    newIndex += 1
                    continue
                }
                
                indexPaths.append(
                    IndexPath(row: oldIndex, section: 0)
                )
                oldIndex += 1
            }
            for i in oldIndex ..< self.itemList.count {
                indexPaths.append(
                    IndexPath(row: i, section: 0)
                )
            }
            
            self.generateItemList(newList, withoutSelectedState: true)
            
            self.tableView.deleteRows(
                at: indexPaths,
                with: self.view.isRtl ? .right : .left
            )
        }
        
        var locationDict = [String: Location]()
        for location in newList.locations {
            locationDict[location.formattedId] = location
        }
        
        // update item.
        for (i, item) in self.itemList.enumerated() {
            if let newLocation = locationDict[item.location.formattedId] {
                let newSelected = item.location.formattedId == newList.selectedId
                
                if item.location != newLocation || item.selected != newSelected {
                    self.itemList[i] = LocationItem(
                        location: newLocation,
                        selected: newSelected
                    )
                    if let cell = self.tableView.cellForRow(
                        at: IndexPath(row: i, section: 0)
                    ) {
                        (cell as? LocationTableViewCell)?.bindData(
                            location: newLocation,
                            selected: newSelected,
                            trans: false
                        )
                    }
                }
            }
        }
        
        if !itemCountChanged {
            // move.
            self.generateItemList(newList, withoutSelectedState: false)
        }
    }
    
    private func generateItemList(
        _ newList: SelectableLocationArray,
        withoutSelectedState: Bool
    ) {
        self.itemList.removeAll()
        
        for location in newList.locations {
            self.itemList.append(
                LocationItem(
                    location: location,
                    selected: !withoutSelectedState
                    && location.formattedId == newList.selectedId
                )
            )
        }
    }
    
    private func indexLocation(
        locations: [Location],
        formattedId: String?
    ) -> Int {
        if let id = formattedId {
            for (i, location) in locations.enumerated() {
                if location.formattedId == id {
                    return i
                }
            }
            return 0
        }
        
        return 0
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
                NSLocalizedString("feedback_collect_succeed", comment: "")
            )
        }
    }
    
    // MARK: - table view delegate & data source.
    
    // data source.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.itemList.count
    }
    
    func dataSourceArray(in tableView: JXMovableCellTableView!) -> NSMutableArray! {
        let outer = NSMutableArray(capacity: 1)
        outer.add(NSMutableArray(array: itemList))
        return outer
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseId,
            for: indexPath
        )
        (cell as? LocationTableViewCell)?.bindData(
            location: self.itemList[indexPath.row].location,
            selected: self.itemList[indexPath.row].selected,
            trans: false
        )
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.param.vm?.setLocation(
            formattedId: self.itemList[indexPath.row].location.formattedId
        )
    }
}
