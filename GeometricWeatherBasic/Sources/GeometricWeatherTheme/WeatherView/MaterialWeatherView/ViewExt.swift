//
//  ViewExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/22.
//

import SwiftUI

extension View {
    
    func onRotate(perform action: @escaping () -> Void) -> some View {
        #if canImport(UIDevice)
        self.modifier(DeviceRotationViewModifier(action: action))
        #else
        self
        #endif
    }
}

#if canImport(UIDevice)
struct DeviceRotationViewModifier: ViewModifier {
    
    @State private var orientation = UIInterfaceOrientation.unknown
    
    public let action: () -> Void

    public func body(content: Content) -> some View {
        
        content.onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.orientationDidChangeNotification
            )
        ) { _ in
            let newValue = UIApplication.shared
                .windows
                .first?
                .windowScene?
                .interfaceOrientation ?? .unknown
            if orientation != newValue {
                orientation = newValue
                self.action()
            }
        }
    }
}
#endif
