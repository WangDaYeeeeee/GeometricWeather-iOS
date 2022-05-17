//
//  ToastHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import UIKit

let shortToastInerval = 1.5
let longToastInterval = 3.0

// MARK: - helper.

class ToastHelper {
    
    static func showToastMessage(
        _ message: String,
        inWindowOf view: UIView,
        WithAction action: String? = nil,
        andDuration duration: TimeInterval = shortToastInerval,
        onCallback callback: (() -> Void)? = nil,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        view.window?.showToastMessage(
            message,
            inWindowOf: view,
            WithAction: action,
            andCallback: callback,
            withDuration: duration,
            completion: completion
        )
    }
}

// MARK: - ext.

extension UIView {
    
    func showToastMessage(
        _ message: String,
        inWindowOf view: UIView,
        WithAction action: String? = nil,
        andCallback callback: (() -> Void)? = nil,
        withDuration duration: TimeInterval = shortToastInerval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        self.showToastView(
            action != nil && callback != nil
            ? ActionableToastView(
                message: message,
                action: action!,
                actionCallback: callback!
            )
            : MessageToastView(
                message: message
            ),
            inWindowOf: view,
            withDuration: duration,
            completion: completion
        )
    }
    
    func showToastView(
        _ toast: UIView,
        inWindowOf view: UIView,
        withDuration duration: TimeInterval = shortToastInerval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        let wrapper = ToastWrapperView(toast: toast)
        
        view.window?.windowScene?.eventBus.register(
            wrapper,
            for: PresentViewControllerEvent.self
        ) { [weak wrapper] _ in
            if let wrapper = wrapper {
                wrapper.superview?.bringSubviewToFront(wrapper)
            }
        }
        
        self.showToast(wrapper, duration: duration, completion: completion)
    }
}
