//
//  Toast-Swift.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/5.
//

import UIKit
import ObjectiveC
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

private enum DisplayEnum: Int {
    case unknown
    case showing
    case hiding
}

extension UIView {
    
    private struct ToastKeys {
        static var status = "com.toast-swift.status"
        static var timer = "com.toast-swift.timer"
        static var duration = "com.toast-swift.duration"
        static var completion = "com.toast-swift.completion"
        static var activeToasts = "com.toast-swift.activeToasts"
        static var queue = "com.toast-swift.queue"
    }
    
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private enum ToastError: Error {
        case missingParameters
    }
    
    private var activeToasts: NSMutableArray {
        get {
            if let activeToasts = objc_getAssociatedObject(
                self,
                &ToastKeys.activeToasts
            ) as? NSMutableArray {
                return activeToasts
            } else {
                let activeToasts = NSMutableArray()
                objc_setAssociatedObject(
                    self,
                    &ToastKeys.activeToasts,
                    activeToasts,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return activeToasts
            }
        }
    }
    
    private var queue: NSMutableArray {
        get {
            if let queue = objc_getAssociatedObject(
                self,
                &ToastKeys.queue
            ) as? NSMutableArray {
                return queue
            } else {
                let queue = NSMutableArray()
                objc_setAssociatedObject(
                    self,
                    &ToastKeys.queue,
                    queue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return queue
            }
        }
    }
    
    // MARK: - Show Toast Methods
    
    func showToast(
        _ toast: ToastWrapperView,
        duration: TimeInterval,
        completion: ((_ didTap: Bool) -> Void)? = nil
    ) {
        objc_setAssociatedObject(
            toast,
            &ToastKeys.completion,
            ToastCompletionWrapper(completion),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        if self.activeToasts.count > 0 {
            self.hideToast()
            
            objc_setAssociatedObject(
                toast,
                &ToastKeys.duration,
                NSNumber(value: duration),
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            self.queue.removeAllObjects()
            self.queue.add(toast)
        } else {
            self.showToast(toast, duration: duration)
        }
    }
    
    private func showToast(_ toast: ToastWrapperView, duration: TimeInterval) {
        objc_setAssociatedObject(
            toast,
            &ToastKeys.status,
            NSNumber(value: DisplayEnum.showing.rawValue),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        self.activeToasts.add(toast)
        self.addSubview(toast)
        
        toast.snp.makeConstraints { make in
            make.width.equalTo(getTabletAdaptiveWidth())
            make.width.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(
                self.safeAreaLayoutGuide.snp.bottom
            )
        }
        
        toast.executeShowAnimation {
            self.registerDelayHideTimer(for: toast, withDuration: duration)
        } dragBeginCallback: { [weak toast] in
            if toast == nil {
                return
            }
            
            if let timer = objc_getAssociatedObject(
                toast!,
                &ToastKeys.timer
            ) as? Timer {
                timer.invalidate()
            }
        } dragEndCallback: { [weak self, weak toast] in
            if let t = toast {
                self?.registerDelayHideTimer(for: t, withDuration: duration)
            }
        } andDragDismissCallback: { [weak self] in
            self?.hideToast()
        }
    }
    
    private func registerDelayHideTimer(
        for toast: ToastWrapperView,
        withDuration duration: Double
    ) {
        let timer = Timer(
            timeInterval: duration,
            target: self,
            selector: #selector(toastTimerDidFinish(_:)),
            userInfo: toast,
            repeats: false
        )
        RunLoop.main.add(timer, forMode: .common)
        objc_setAssociatedObject(
            toast,
            &ToastKeys.timer,
            timer,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
    
    // MARK: - Hide Toast Methods
    
    func hideToast() {
        guard let activeToast = activeToasts.firstObject as? ToastWrapperView else {
            return
        }
        self.hideToast(activeToast, fromTap: false)
    }
    
    func hideToast(_ toast: ToastWrapperView, fromTap: Bool) {
        guard let statusInt = objc_getAssociatedObject(
            toast,
            &ToastKeys.status
        ) as? NSNumber else {
            return
        }
        
        let status = DisplayEnum(rawValue: statusInt.intValue) ?? .unknown
        if status != .showing {
            return
        }
        
        objc_setAssociatedObject(
            toast,
            &ToastKeys.status,
            NSNumber(value: DisplayEnum.hiding.rawValue),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        if let timer = objc_getAssociatedObject(
            toast,
            &ToastKeys.timer
        ) as? Timer {
            timer.invalidate()
        }
        
        toast.executeHideAnimation {
            toast.removeFromSuperview()
            self.activeToasts.remove(toast)
            
            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper,
                let completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.firstObject as? ToastWrapperView,
                let duration = objc_getAssociatedObject(
                    nextToast,
                    &ToastKeys.duration
                ) as? NSNumber {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue)
            }
        }
    }
    
    func hideAllToasts(
        includeActivity: Bool = false,
        clearQueue: Bool = true
    ) {
        if clearQueue {
            self.clearToastQueue()
        }
        
        self.activeToasts.compactMap {
            $0 as? ToastWrapperView
        }.forEach {
            self.hideToast($0, fromTap: false)
        }
    }
    
    func clearToastQueue() {
        self.queue.removeAllObjects()
    }
    
    // MARK: - Events
    
    @objc private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? ToastWrapperView else {
            return
        }
        self.hideToast(toast, fromTap: false)
    }
}
