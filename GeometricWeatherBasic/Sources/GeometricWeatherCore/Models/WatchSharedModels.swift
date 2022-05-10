//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/5/10.
//

import Foundation

public struct SharedLocationUpdateResult: Codable {
    
    public let location: Location
    
    public init(location: Location) {
        self.location = location
    }
}
