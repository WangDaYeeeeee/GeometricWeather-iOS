//
//  Pollen.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct Pollen: Codable {
    
    public let grassIndex: Int?
    public let grassLevel: Int?
    public let grassDescription: String?
    
    public let moldIndex: Int?
    public let moldLevel: Int?
    public let moldDescription: String?
    
    public let ragweedIndex: Int?
    public let ragweedLevel: Int?
    public let ragweedDescription: String?
    
    public let treeIndex: Int?
    public let treeLevel: Int?
    public let treeDescription: String?

    public init(
        grassIndex: Int?,
        grassLevel: Int?,
        grassDescription: String?,
        moldIndex: Int?,
        moldLevel: Int?,
        moldDescription: String?,
        ragweedIndex: Int?,
        ragweedLevel: Int?,
        ragweedDescription: String?,
        treeIndex: Int?,
        treeLevel: Int?,
        treeDescription: String?
    ) {
        self.grassIndex = grassIndex
        self.grassLevel = grassLevel
        self.grassDescription = grassDescription
        self.moldIndex = moldIndex
        self.moldLevel = moldLevel
        self.moldDescription = moldDescription
        self.ragweedIndex = ragweedIndex
        self.ragweedLevel = ragweedLevel
        self.ragweedDescription = ragweedDescription
        self.treeIndex = treeIndex
        self.treeLevel = treeLevel
        self.treeDescription = treeDescription
    }
    
    public func isValid() -> Bool {
        return (grassIndex != nil && grassIndex! > 0 && grassLevel != nil)
                || (moldIndex != nil && moldIndex! > 0 && moldLevel != nil)
                || (ragweedIndex != nil && ragweedIndex! > 0 && ragweedLevel != nil)
                || (treeIndex != nil && treeIndex! > 0 && treeLevel != nil)
    }

    public static func getPollenLevel(level: Int?) -> Int {
        if (level == nil) {
            return 1
        } else if (level! <= 1) {
            return 1
        } else if (level! <= 2) {
            return 2
        } else if (level! <= 3) {
            return 3
        } else if (level! <= 4) {
            return 4
        } else if (level! <= 5) {
            return 5
        } else {
            return 6
        }
    }
}
