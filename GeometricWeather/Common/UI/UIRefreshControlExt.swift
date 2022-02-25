//
//  UIRefreshControlExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/15.
//

import Foundation

extension UIRefreshControl {
    
    func beginRefreshingWithOffset() {
        if let scrollView = self.superview as? UIScrollView {
            scrollView.setContentOffset(
                CGPoint(
                    x: 0,
                    y: scrollView.contentOffset.y - self.frame.height
                ),
                animated: false
            )
        }
        self.beginRefreshing()
    }
}
