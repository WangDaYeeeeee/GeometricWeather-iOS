//
//  BaseManagementController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/25.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import UIKit

private let cellReuseId = "ManagementTableViewCell"

enum ManagementSection: Hashable {
    case locationItems
}

class BaseManagementController: GeoViewController<MainViewModel>,
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
    let tableView: JXMovableCellTableView = {
        let view = JXMovableCellTableView(frame: .zero, style: .plain)
        
        view.backgroundColor = .clear
        view.cellLayoutMarginsFollowReadableWidth = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.allowsSelection = true
        view.allowsMultipleSelection = false
        view.allowsSelectionDuringEditing = true
        view.separatorStyle = .singleLine
        view.separatorColor = .opaqueSeparator.withAlphaComponent(0.5)
        view.separatorInset = .zero
        view.tableFooterView = UIView(frame: .zero)
        view.rowHeight = LocationTableViewCell.cellHeight
        view.register(
            LocationTableViewCell.self,
            forCellReuseIdentifier: cellReuseId
        )
        
        return view
    }()
    
    private let dragBeginImpactor = UIImpactFeedbackGenerator(style: .heavy)
    private let dragReactionImpactor = UIImpactFeedbackGenerator(style: .rigid)
    private let dragFailedImpactor = UINotificationFeedbackGenerator()
    
    // MARK: - life cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    // MARK: - ui.
    
    func dismiss() {
        // do nothing.
    }
    
    func updateLocationList(_ newList: SelectableLocationArray) {
        let prevItemList = self.itemList
        let nextItemList = self.generateItemList(newList, withoutSelectedState: false)
        if prevItemList.isEmpty {
            self.itemList = nextItemList;
            self.tableView.reloadData()
            return
        }
        
        let diffResult = DiffResult.diff(at: 0, between: prevItemList, and: nextItemList)
        
        if !diffResult.insertedItems.isEmpty
            || !diffResult.deletedItems.isEmpty {
            self.tableView.performBatchUpdates({
                self.itemList = nextItemList
                
                self.tableView.deleteRows(at: diffResult.deletedItems, with: .fade)
                self.tableView.insertRows(at: diffResult.insertedItems, with: .none)
                self.tableView.reloadRows(at: diffResult.reloadedItems, with: .fade)
            }, completion: nil)
            return
        }
        
        self.itemList = nextItemList
        if diffResult.reloadedItems.isEmpty {
            return
        }
        for item in diffResult.reloadedItems {
            if let cell = self.tableView.cellForRow(at: item) as? LocationTableViewCell {
                cell.bindData(
                    location: self.itemList[item.row].location,
                    selected: self.itemList[item.row].selected,
                    withTransparentBackground: self.transparentCell
                )
            }
        }
    }
    
    private func generateItemList(
        _ newList: SelectableLocationArray,
        withoutSelectedState: Bool
    ) -> [LocationItem] {
        return newList.locations.map { location in
            return LocationItem(
                location: location,
                selected: !withoutSelectedState && location.formattedId == newList.selectedId
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
            withTransparentBackground: self.transparentCell
        )
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.param.setLocation(
            formattedId: self.itemList[indexPath.row].location.formattedId
        )
        self.dismiss()
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
            guard let strongSelf = self else {
                return
            }
            
            if let location = strongSelf.itemList.get(indexPath.row)?.location {
                if !location.residentPosition {
                    let window = strongSelf.view.window
                    
                    ToastHelper.showToastMessage(
                        getLocalizedText("feedback_resident_location"),
                        inWindowOf: strongSelf.view,
                        WithAction: getLocalizedText("learn_more"),
                        andDuration: longToastInterval
                    ) {
                        if let window = window {
                            StatementDialog(
                                title: getLocalizedText("feedback_resident_location"),
                                content: getLocalizedText("feedback_resident_location_description")
                            ).showOn(window)
                        }
                    } completion: { didTap in
                        // do nothing.
                    }
                }
                
                strongSelf.param.updateLocation(
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
            if let view = self?.view {
                ToastHelper.showToastMessage(
                    getLocalizedText("feedback_delete_succeed"),
                    inWindowOf: view
                )
            }
            
            self?.param.deleteLocation(position: indexPath.row)
            handler(true)
        }
        delete.image = UIImage(systemName: "minus.circle.fill")
        delete.backgroundColor = .systemRed
        
        var actions = [UIContextualAction]()
        if self.itemList.count > 1 {
            actions.append(delete)
        }
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
        _ tableView: UITableView,
        canMoveRowAt indexPath: IndexPath
    ) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return true
        }
        
        return cell.frame.origin.x == 0
    }
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        tryMoveUnmovableCellAt indexPath: IndexPath!
    ) {
        self.dragFailedImpactor.notificationOccurred(.error)
    }
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        customizeMovalbeCell movableCellsnapshot: UIImageView!
    ) {
        movableCellsnapshot.layer.cornerRadius = 0
        movableCellsnapshot.layer.masksToBounds = false
        movableCellsnapshot.layer.shadowColor = UIColor.black.cgColor
        movableCellsnapshot.layer.shadowOpacity = 0.2
        movableCellsnapshot.layer.shadowOffset = .zero
        movableCellsnapshot.layer.shadowRadius = 16.0
    }
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        willMoveCellAt indexPath: IndexPath!
    ) {
        self.dragBeginImpactor.impactOccurred()
        self.moveBeginIndex = indexPath
    }
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        didMoveCellFrom fromIndexPath: IndexPath!,
        to toIndexPath: IndexPath!
    ) {
        self.dragReactionImpactor.impactOccurred()
    }
    
    func tableView(
        _ tableView: JXMovableCellTableView!,
        endMoveCellAt indexPath: IndexPath!
    ) {
        self.dragReactionImpactor.impactOccurred()
        
        if let beginAt = self.moveBeginIndex {
            self.param.moveLocation(
                from: beginAt.row,
                to: indexPath.row
            )
        }
    }
}
