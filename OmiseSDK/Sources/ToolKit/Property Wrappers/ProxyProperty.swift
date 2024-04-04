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

    /// Proxy can only be applied to classes
    var wrappedValue: Value {
        get { fatalError("Can't use wrappedValue on ProxyProperty") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("Can't use wrappedValue on ProxyProperty") }
    }

    private let keyPath: ValueKeyPath

    init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }
}
