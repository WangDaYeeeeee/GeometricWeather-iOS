//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/5/10.
//

import Foundation

public struct SharedLocationUpdateResult: Codable {
    
    public let locations: [Location]
    
    public init(locations: [Location]) {
        self.locations = locations
    }
}
