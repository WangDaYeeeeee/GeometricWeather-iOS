//
//  Log.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/27.
//

import Foundation

private let dateFormatter = DateFormatter()
private let dateFormat = "yyyy-MM-dd HH:mm:ss"

public func printLog(
    keyword: String,
    content: String
) {
    dateFormatter.dateFormat = dateFormat
    
    print("\(dateFormatter.string(from: Date())) --- \(keyword) --- \(content)")
}
