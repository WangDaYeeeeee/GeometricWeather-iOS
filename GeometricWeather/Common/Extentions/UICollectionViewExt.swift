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

public extension UICollectionView.ScrollPosition {
    
    static var start: UICollectionView.ScrollPosition {
        return Self.isRtl ? .right : .left
    }
    
    static var end: UICollectionView.ScrollPosition {
        return Self.isRtl ? .left : .right
    }
    
    static var isRtl: Bool {
        get {
            if let language = (
                UserDefaults.standard.object(
                    forKey: "AppleLanguages"
                ) as? [String]
            )?.first {
                return language.hasPrefix("ar")
            }
            
            return false
        }
    }
}
