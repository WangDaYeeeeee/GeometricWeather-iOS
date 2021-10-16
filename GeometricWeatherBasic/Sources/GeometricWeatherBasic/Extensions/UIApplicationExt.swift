//
//  File.swift
//  
//
//  Created by 王大爷 on 2021/10/14.
//

import UIKit

public extension UIApplication {
    
    var keyWindowInCurrentScene: UIWindow? {
        get {
            return UIApplication.shared.connectedScenes.filter {
                $0.activationState == .foregroundActive
            }.first(
                where: { $0 is UIWindowScene }
            ).flatMap(
                { $0 as? UIWindowScene }
            )?.windows.first(
                where: \.isKeyWindow
            )
        }
    }
    
}
