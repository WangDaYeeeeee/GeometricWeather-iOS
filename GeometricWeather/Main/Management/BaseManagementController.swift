//
//  BaseManagementController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/25.
//

import Foundation
import GeometricWeatherBasic

private let cellReuseId = "ManagementTableViewCell"

class BaseManagementController: GeoViewController<MainViewModelWeakRef>,
                                    JXMovableCellTableViewDataSource,
                                    JXMovableCellTableViewDelegate {
    
    // MARK: - inner data.
    
    var itemList = [LocationItem]()
    var moveBeginIndex: IndexPath?
    
    var transparentCell: Bool {
        get {
            return true
        }
    }
    let tableView = JXMovableCellTableView(frame: .zero, style: .plain)
    
    // MARK: - ui.
    enum UpdateLocationListResult {
        case new
        case added
        case deleted
        case others
    }
    func updateLocationList(
        _ newList: SelectableLocationArray
    ) -> UpdateLocationListResult {
        var result = UpdateLocationListResult.others
        
        // new.
        if self.itemList.isEmpty {
            result = .new
            
            self.generateItemList(newList, withoutSelectedState: false)
            self.tableView.reloadData()
            
            return result
        }
        
        let itemCountChanged = self.itemList.count != newList.locations.count
        
        if self.itemList.count < newList.locations.count {
            // add.
            result = .added
            
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
            result = .deleted
            
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
                            trans: self.transparentCell
                        )
                    }
                }
            }
        }
        
        if !itemCountChanged {
            // move.
            self.generateItemList(newList, withoutSelectedState: false)
        }
        
        return result
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
            trans: self.transparentCell
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
        self.dismiss(animated: true)
    }
    
    // swipe reaction.
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let residientPosition = UIContextualAction(
            style: .destructive,
            title: nil
        ) { [weak self] action, view, handler in
            if let location = self?.itemList.get(indexPath.row)?.location {
                if !location.residentPosition {
                    ToastHelper.showToastMessage(
                        NSLocalizedString("feedback_resident_location", comment: ""),
                        inWindowOfView: view,
                        WithAction: NSLocalizedString("learn_more", comment: ""),
                        andDuration: longToastInterval
                    ) {
                        StatementDialog(
                            title: NSLocalizedString(
                                "feedback_resident_location",
                                comment: ""
                            ),
                            content: NSLocalizedString(
                                "feedback_resident_location_description",
                                comment: ""
                            )
                        ).showSelf(inWindowOfView: view)
                    } completion: { didTap in
                        // do nothing.
                    }
                }
                
                self?.param.vm?.updateLocation(
                    location: location.copyOf(
                        residentPosition: !location.residentPosition
                    )
                )
            }
            handler(true)
        }
        residientPosition.image = UIImage(
            systemName: (
                self.itemList.get(indexPath.row)?.location.residentPosition ?? false
            ) ? "xmark.seal.fill" : "checkmark.seal.fill"
        )
        residientPosition.backgroundColor = .systemBlue
        
        let delete = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] action, view, handler in
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_delete_succeed", comment: ""),
                inWindowOfView: view
            )
            
            self?.param.vm?.deleteLocation(position: indexPath.row)
            handler(true)
        }
        delete.image = UIImage(systemName: "delete.backward.fill")
        delete.backgroundColor = .systemRed
        
        var actions = [UIContextualAction]()
        actions.append(delete)
        if !(
            self.itemList.get(
                indexPath.row
            )?.location.currentPosition ?? false
        ) {
            actions.append(residientPosition)
        }
        
        let config = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    // drag reaction.
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        willMoveCellAt indexPath: IndexPath!
    ) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        self.moveBeginIndex = indexPath
    }
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        endMoveCellAt indexPath: IndexPath!
    ) {
        if let beginAt = self.moveBeginIndex {
            self.param.vm?.moveLocation(
                from: beginAt.row,
                to: indexPath.row
            )
        }
    }
}
