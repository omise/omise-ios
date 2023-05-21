//
//  ProxyProperty.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 21/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import Foundation

@propertyWrapper
struct ProxyProperty<EnclosingType, Value> {
    typealias ValueKeyPath = ReferenceWritableKeyPath<EnclosingType, Value>
    typealias SelfKeyPath = ReferenceWritableKeyPath<EnclosingType, Self>

    static subscript(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: ValueKeyPath,
        storage storageKeyPath: SelfKeyPath
    ) -> Value {
        get {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            return instance[keyPath: keyPath]
        }
        set {
            let keyPath = instance[keyPath: storageKeyPath].keyPath
            instance[keyPath: keyPath] = newValue
        }
    }

    @available(*, unavailable, message: "@Proxy can only be applied to classes")
    var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }

    private let keyPath: ValueKeyPath

    init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }
}
