//
//  MainTrendGenerator.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/6/15.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources

// MARK: - main.

class MainTrendGenerator: NSObject {
    
    static var key: String {
        return String(reflecting: Self.self)
    }
}

protocol MainTrendGeneratorProtocol: MainTrendGenerator {
    
    init(_ location: Location)
    
    var dispayName: String { get }
    var isValid: Bool { get }
    
    static func registerCellClass(to collectionView: UICollectionView)
    func bindCellData(
        at indexPath: IndexPath,
        to collectionView: UICollectionView
    ) -> UICollectionViewCell
    func bindCellBackground(to trendBackgroundView: MainTrendBackgroundView)
}
