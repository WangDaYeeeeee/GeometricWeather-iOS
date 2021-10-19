//
//  ToastHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/14.
//

import Foundation

class ToastHelper {
    
    static func showToastMessage(
        _ message: String,
        WithAction action: String? = nil,
        andDuration duration: TimeInterval = shortToastInerval,
        onCallback callback: (() -> Void)? = nil,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        UIApplication.shared.keyWindowInCurrentScene?.showToastMessage(
            message,
            WithAction: action,
            andCallback: callback,
            withDuration: duration,
            completion: completion
        )
    }
}

// MARK: - ext.

let shortToastInerval = 1.5
let longToastInterval = 3.0

extension UIView {
    
    func showToastMessage(
        _ message: String,
        WithAction action: String? = nil,
        andCallback callback: (() -> Void)? = nil,
        withDuration duration: TimeInterval = shortToastInerval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        self.showToastView(
            action != nil && callback != nil ? ActionableToastView(
                message: message,
                action: action!,
                actionCallback: callback!
            ) : MessageToastView(
                message: message
            ),
            withDuration: duration,
            completion: completion
        )
    }
    
    func showToastView(
        _ toast: UIView,
        withDuration duration: TimeInterval = shortToastInerval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        self.showToast(
            ToastWrapperView(toast: toast),
            duration: duration,
            completion: completion
        )
    }
}
