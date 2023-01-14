//
//  Diff.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2023/1/14.
//

import Foundation

// MARK: - diffable.

protocol Diffable {
    
    var identifier: String { get }
    var contentKey: String { get }
    var obj: NSObject { get }
}

// MARK: - move item.

struct DiffMoveItem {
    
    let from: IndexPath
    let to: IndexPath
}

// MARK: - calculator.

struct DiffResult {
    
    let deletedItems: [IndexPath]
    let insertedItems: [IndexPath]
    let reloadedItems: [IndexPath]
    let movedItems: [DiffMoveItem]
    
    let isExistRepeatItems: Bool
    
    private struct DiffKeys {
        static var oldIdentifier = "com.wangdaye.geometricweather.diff.oldIdentifier"
        static var newIdentifier = "com.wangdaye.geometricweather.diff.newIdentifier"
    }
    
    private static let repeatResult = DiffResult(
        deletedItems: [],
        insertedItems: [],
        reloadedItems: [],
        movedItems: [],
        isExistRepeatItems: true
    )
    
    static func diff(
        at section: Int,
        between oldItems: [Diffable],
        and newItems: [Diffable]
    ) -> DiffResult {
        var deletedItems = [IndexPath]()
        var insertedItems = [IndexPath]()
        var reloadedItems = [IndexPath]()
        var movedItems = [DiffMoveItem]()
                
        // build identifer-index map for old items and new items.
        // if there were repeat items in old items or new items, end diff directly.
        
        var oldIdIndexMap = Dictionary<String, Int>()
        var newIdIndexMap = Dictionary<String, Int>()
        for (i, item) in oldItems.enumerated() {
            let id = item.identifier
            if oldIdIndexMap[id] != nil {
                return repeatResult
            }
            oldIdIndexMap[id] = i
        }
        for (i, item) in newItems.enumerated() {
            let id = item.identifier
            if newIdIndexMap[id] != nil {
                return repeatResult
            }
            newIdIndexMap[id] = i
        }
        
        // select deleted items.
        
        for (i, item) in oldItems.enumerated() {
            let indexPath = IndexPath(item: i, section: section)
            
            if newIdIndexMap[item.identifier] == nil {
                deletedItems.append(indexPath)
            }
        }
        
        // select inserted items.
        
        for (i, item) in newItems.enumerated() {
            let indexPath = IndexPath(item: i, section: section)
            
            if oldIdIndexMap[item.identifier] == nil {
                insertedItems.append(indexPath)
            }
        }
        
        // select moved items and reloaded items.
        
        for (i, item) in oldItems.enumerated() {
            let oldId = item.identifier
            let oldIndexPath = IndexPath(item: i, section: section)
            guard let newIndex = newIdIndexMap[oldId] else {
                continue
            }
            
            if newIndex != i {
                let newIndexPath = IndexPath(item: newIndex, section: section)
                let moveItem = DiffMoveItem(from: oldIndexPath, to: newIndexPath)
                movedItems.append(moveItem)
                continue
            }
            
            let newItem = newItems[newIndex]
            if newItem.contentKey != item.contentKey {
                reloadedItems.append(oldIndexPath)
            }
        }
        
        return DiffResult(
            deletedItems: deletedItems,
            insertedItems: insertedItems,
            reloadedItems: reloadedItems,
            movedItems: movedItems,
            isExistRepeatItems: false
        )
    }
}

extension UITableView {
    
    func reload(
        section: Int,
        from oldData: [Diffable],
        to newData: [Diffable],
        by animation: RowAnimation,
        with dataUpdator: @escaping (([Diffable]) -> Void),
        completion: (() -> Void)?
    ) {
        let diffResult = DiffResult.diff(at: section, between: oldData, and: newData)
        if (Thread.isMainThread) {
            self.reload(
                because: diffResult,
                for: newData,
                by: animation,
                with: dataUpdator,
                completion: completion
            )
        } else {
            DispatchQueue.main.async {
                self.reload(
                    because: diffResult,
                    for: newData,
                    by: animation,
                    with: dataUpdator,
                    completion: completion
                )
            }
        }
    }
    
    private func reload(
        because diffResult: DiffResult,
        for newData: [Diffable],
        by animation: RowAnimation,
        with dataUpdator: (([Diffable]) -> Void),
        completion: (() -> Void)?
    ) {
        self.performBatchUpdates {
            dataUpdator(newData)
            
            if !diffResult.deletedItems.isEmpty {
                self.deleteRows(at: diffResult.deletedItems, with: animation)
            }
            if !diffResult.insertedItems.isEmpty {
                self.insertRows(at: diffResult.insertedItems, with: animation)
            }
            if !diffResult.reloadedItems.isEmpty {
                self.reloadRows(at: diffResult.reloadedItems, with: animation)
            }
            
            diffResult.movedItems.forEach { item in
                self.moveRow(at: item.from, to: item.to)
            }
        } completion: { done in
            if done {
                completion?()
            }
        }
    }
}
