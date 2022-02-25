//
//  ManagementViewController+Editable.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import Foundation

extension SplitManagementViewController {
    
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
                        ).showSelf()
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
                NSLocalizedString("feedback_delete_succeed", comment: "")
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
