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
            let contentOffsetY = Int(scrollView.contentOffset.y);
            let insetsTop = Int(scrollView.adjustedContentInset.top);
            
            if (-contentOffsetY == insetsTop) {
                scrollView.setContentOffset(
                    CGPoint(
                        x: 0,
                        y: scrollView.contentOffset.y - self.frame.height
                    ),
                    animated: false
                )
            }
        }
        self.beginRefreshing()
    }
}
