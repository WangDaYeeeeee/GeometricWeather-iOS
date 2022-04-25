//
//  ViewExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/22.
//

import SwiftUI

public extension View {
    
    func onRotate(
        perform action:
        @escaping (UIInterfaceOrientation) -> Void
    ) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

public struct DeviceRotationViewModifier: ViewModifier {
    
    @State private var orientation = UIInterfaceOrientation.unknown
    
    public let action: (UIInterfaceOrientation) -> Void

    public func body(content: Content) -> some View {
        
        content.onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.orientationDidChangeNotification
            )
        ) { _ in
            let newValue = getUIOrientation()
            if orientation != newValue {
                orientation = newValue
                action(orientation)
            }
        }
    }
}
