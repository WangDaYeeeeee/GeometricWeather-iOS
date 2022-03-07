//
//  UIViewPropertyAnimatorExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/3/7.
//

import Foundation

infix operator ~>: AdditionPrecedence

@discardableResult
func ~>(
    left: UIViewPropertyAnimator,
    right: UIViewPropertyAnimator
) -> UIViewPropertyAnimator{

    left.addCompletion { position in
        if position == .end {
            right.startAnimation()
        }
    }

    return right
}
