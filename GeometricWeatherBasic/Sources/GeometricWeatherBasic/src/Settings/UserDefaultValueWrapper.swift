//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/4/21.
//

import Foundation

@propertyWrapper
private struct _UserDefaultValueWrapper<ValueType> {
    
    let key: String
    let defaultValue: ValueType
    
    var wrappedValue: ValueType {
        get {
            return UserDefaults.shared.object(
                forKey: self.key
            ) as? ValueType ?? self.defaultValue
        }
        set {
            UserDefaults.shared.set(newValue, forKey: self.key)
        }
    }
    
    init(
        key: String,
        defaultValue: ValueType
    ) {
        self.key = key
        self.defaultValue = defaultValue
        
        UserDefaults.standard.register(defaults: [self.key: self.defaultValue])
    }
}

@propertyWrapper
struct UserDefaultValueWrapper<ValueType, NotificationType>
where NotificationType: SettingsValueEvent<ValueType> {
    
    private var impl: _UserDefaultValueWrapper<ValueType>
    
    var wrappedValue: ValueType {
        get {
            return self.impl.wrappedValue
        }
        set {
            self.impl.wrappedValue = newValue
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(NotificationType(newValue))
        }
    }
    
    init(
        key: String,
        defaultValue: ValueType
    ) {
        self.impl = _UserDefaultValueWrapper(key: key, defaultValue: defaultValue)
    }
}

@propertyWrapper
struct ConvertableUserDefaultValueWrapper<OriginValueType, InterfaceValueType, NotificationType>
where NotificationType: SettingsValueEvent<InterfaceValueType> {
    
    private var impl: _UserDefaultValueWrapper<OriginValueType>
    let interfaceTypeToOrigin: (InterfaceValueType) -> OriginValueType
    let originTypeToInterface: (OriginValueType) -> InterfaceValueType
    
    var wrappedValue: InterfaceValueType {
        get {
            return self.originTypeToInterface(self.impl.wrappedValue)
        }
        set {
            self.impl.wrappedValue = self.interfaceTypeToOrigin(newValue)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(NotificationType(newValue))
        }
    }
    
    init(
        key: String,
        defaultValue: InterfaceValueType,
        interfaceTypeToOrigin: @escaping (InterfaceValueType) -> OriginValueType,
        originTypeToInterface: @escaping (OriginValueType) -> InterfaceValueType
    ) {
        self.impl = _UserDefaultValueWrapper(key: key, defaultValue: interfaceTypeToOrigin(defaultValue))
        self.interfaceTypeToOrigin = interfaceTypeToOrigin
        self.originTypeToInterface = originTypeToInterface
    }
}
