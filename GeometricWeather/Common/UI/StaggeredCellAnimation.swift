//
//  StaggeredCellAnimation.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/8.
//

import UIKit
import GeometricWeatherBasic

extension UIView {
    
    @objc func staggeredScrollIntoScreen(atFirstTime: Bool) {
        
    }
    
    @objc func staggeredScrollOutScreen() {
        
    }
}

private let defaultStaggeredBaseDuration = 3.0
private let defaultStaggeredInitOffset = CGSize(width: 0, height: 64)
private let defaultStaggeredInitScale = CGSize(width: 1.1, height: 1.1)
private let defaultUnitDelay = 0.15
private let defaultDurationUnitDumping = 0.05

class StaggeredCellAnimationHelper: NSObject,
                                        UITableViewDelegate,
                                        UICollectionViewDelegate {
    
    var lastIndexPath = IndexPath(row: -1, section: -1)
    private var animatingIndexPaths = Set<IndexPath>()
    
    private let baseDuration: Double
    private let initOffset: CGSize
    private let initScale: CGSize
    private let unitDelay: Double
    private let durationUnitDumping: Double
    
    // MARK: - life cycle.
    
    init(
        baseDuration: Double = defaultStaggeredBaseDuration,
        initOffset: CGSize = defaultStaggeredInitOffset,
        initScale: CGSize = defaultStaggeredInitScale,
        unitDelay: Double = defaultUnitDelay,
        durationUnitDumping: Double = defaultDurationUnitDumping
    ) {
        self.baseDuration = baseDuration
        self.initOffset = initOffset
        self.initScale = initScale
        self.unitDelay = unitDelay
        self.durationUnitDumping = durationUnitDumping
    }
    
    func reset() {
        self.lastIndexPath = IndexPath(row: -1, section: -1)
        self.animatingIndexPaths = Set<IndexPath>()
    }
    
    // MARK: - interfaces.
    
    func isShownIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section < self.lastIndexPath.section || (
            indexPath.section == self.lastIndexPath.section
            && indexPath.row <= self.lastIndexPath.row
        )
    }
    
    func compareIndexPaths(left: IndexPath, right: IndexPath) -> Int {
        if left.section != right.section {
            return left.section - right.section
        }
        return left.row - right.row
    }
    
    private func clearViewAnimations(_ view: UIView, indexPath: IndexPath) {
        self.animatingIndexPaths.remove(indexPath)
        
        view.layer.removeAllAnimations()
        view.alpha = 1
        view.transform = CGAffineTransform(
            translationX: 0,
            y: 0
        ).concatenating(
            CGAffineTransform(scaleX: 1.0, y: 1.0)
        )
    }
    
    private func on(viewEnterScreen view : UIView, at indexPath: IndexPath) {
        
        if self.compareIndexPaths(
            left: indexPath,
            right: self.lastIndexPath
        ) > 0 {
            // view index > last index. -> execute animation.
            
            view.layer.removeAllAnimations()
            view.alpha = 0
            view.transform = CGAffineTransform(
                translationX: self.initOffset.width,
                y: self.initOffset.height
            ).concatenating(
                CGAffineTransform(
                    scaleX: self.initScale.width,
                    y: self.initScale.height
                )
            )
            
            let duration = max(
                self.baseDuration - self.durationUnitDumping * Double(
                    self.animatingIndexPaths.count
                ),
                self.baseDuration / 2
            )
            let delay = Double(self.animatingIndexPaths.count) * self.unitDelay
            
            self.lastIndexPath = indexPath
            self.animatingIndexPaths.insert(indexPath)
            
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.5,
                options: [.allowUserInteraction, .beginFromCurrentState]
            ) {
                view.alpha = 1
                view.transform = CGAffineTransform(
                    translationX: 0,
                    y: 0
                ).concatenating(
                    CGAffineTransform(scaleX: 1, y: 1)
                )
            } completion: { [weak self] finished in
                if !finished {
                    return
                }
                self?.clearViewAnimations(view, indexPath: indexPath)
            }
            
            view.staggeredScrollIntoScreen(atFirstTime: true)
        } else if !self.animatingIndexPaths.contains(indexPath) {
            // cell index <= last index. -> do not execute animation.
            self.clearViewAnimations(view, indexPath: indexPath)
            
            view.staggeredScrollIntoScreen(atFirstTime: false)
        }
    }
    
    private func on(viewExitScreen view : UIView, at indexPath: IndexPath) {
        self.clearViewAnimations(view, indexPath: indexPath)
        view.staggeredScrollOutScreen()
    }
    
    // MARK: - table view delegate.
    
    // header.
    
    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        self.on(viewEnterScreen: view, at: IndexPath(row: -1, section: section))
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplayingHeaderView view: UIView,
        forSection section: Int
    ) {
        self.on(viewExitScreen: view, at: IndexPath(row: -1, section: section))
    }
    
    // footer.
    
    func tableView(
        _ tableView: UITableView,
        willDisplayFooterView view: UIView,
        forSection section: Int
    ) {
        self.on(viewEnterScreen: view, at: IndexPath(row: .max, section: section))
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplayingFooterView view: UIView,
        forSection section: Int
    ) {
        self.on(viewExitScreen: view, at: IndexPath(row: .max, section: section))
    }
    
    // cells.
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        self.on(viewEnterScreen: cell, at: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        self.on(viewExitScreen: cell, at: indexPath)
    }
    
    // MARK: - collection view delegate.
    
    // supplementaries.
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        self.on(viewEnterScreen: view, at: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        self.on(viewExitScreen: view, at: indexPath)
    }
    
    // cells.
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        self.on(viewEnterScreen: cell, at: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        self.on(viewExitScreen: cell, at: indexPath)
    }
}
