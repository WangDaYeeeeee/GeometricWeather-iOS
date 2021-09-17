//
//  Pollen.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct Pollen: Codable {
    
    let grassIndex: Int?
    let grassLevel: Int?
    let grassDescription: String?
    
    let moldIndex: Int?
    let moldLevel: Int?
    let moldDescription: String?
    
    let ragweedIndex: Int?
    let ragweedLevel: Int?
    let ragweedDescription: String?
    
    let treeIndex: Int?
    let treeLevel: Int?
    let treeDescription: String?

    init(
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
    
    func isValid() -> Bool {
        return (grassIndex != nil && grassIndex! > 0 && grassLevel != nil)
                || (moldIndex != nil && moldIndex! > 0 && moldLevel != nil)
                || (ragweedIndex != nil && ragweedIndex! > 0 && ragweedLevel != nil)
                || (treeIndex != nil && treeIndex! > 0 && treeLevel != nil)
    }

    static func getPollenLevel(level: Int?) -> Int {
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
