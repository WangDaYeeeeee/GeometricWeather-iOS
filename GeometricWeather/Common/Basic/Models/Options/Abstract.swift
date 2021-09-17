//
//  Abstract.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

protocol Option {
    
    associatedtype ImplType: Option
    
    static var all: Array<ImplType> { get }
    
    static subscript(index: Int) -> ImplType { get }
    
    static subscript(key: String) -> ImplType { get }
    
    var key: String { get }
}

protocol ReadableOption: Option {
    
    var voiceKey: String { get }
}

typealias ValueConverter<ValueType> = (ValueType) -> ValueType

protocol Unit: ReadableOption {
    
    associatedtype ValueType
    
    var valueConterver: ValueConverter<ValueType> { get }
    
    func getValue(_ valueInDefaultType: ValueType) -> ValueType
    
    func formatValue(_ valueInDefaultType: ValueType) -> String
    
    func formatValueWithUnit(_ valueInDefaultType: ValueType, unit: String) -> String
}
