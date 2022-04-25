//
//  UICollectionViewExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/15.
//

import UIKit

public extension UICollectionView {

    func safeReloadData() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.reloadData()
        CATransaction.commit()
    }

    func safeLayoutInvalidateLayout() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.collectionViewLayout.invalidateLayout()
        CATransaction.commit()
    }
}
