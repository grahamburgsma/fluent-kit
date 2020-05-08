extension Fields {
    public typealias Enum<Value> = EnumProperty<Self, Value>
        where Value: Codable,
            Value: RawRepresentable,
            Value.RawValue == String
}

// MARK: Type

@propertyWrapper
public final class EnumProperty<Model, Value>
    where Model: FluentKit.Fields,
        Value: Codable,
        Value: RawRepresentable,
        Value.RawValue == String
{
    public let field: FieldProperty<Model, String>

    public var projectedValue: EnumProperty<Model, Value> {
        return self
    }

    public var wrappedValue: Value {
        get {
            guard let value = self.value else {
                fatalError("Cannot access enum field before it is initialized or fetched: \(self.field.key)")
            }
            return value
        }
        set {
            self.value = newValue
        }
    }

    public init(key: FieldKey) {
        self.field = .init(key: key)
    }
}

// MARK: Property

extension EnumProperty: AnyProperty { }

extension EnumProperty: Property {
    public var value: Value? {
        get {
            if let value = self.field.inputValue {
                switch value {
                case .enumCase(let string):
                    return Value(rawValue: string)!
                case .bind(let string as String):
                    guard let value = Value(rawValue: string) else {
                        fatalError("Invalid enum case name '\(string)' for enum \(Value.self)")
                    }

                    return value
                default:
                    fatalError("Unexpected enum input value type: \(value)")
                }
            } else if let value = self.field.outputValue {
                return Value(rawValue: value)!
            } else {
                return nil
            }
        }
        set {
            self.field.inputValue = newValue.flatMap {
                .enumCase($0.rawValue)
            }
        }
    }
}

// MARK: Queryable

extension EnumProperty: AnyQueryableProperty {
    public var path: [FieldKey] {
        self.field.path
    }
}

extension EnumProperty: QueryableProperty {
    public static func queryValue(_ value: Value) -> DatabaseQuery.Value {
        .enumCase(value.rawValue)
    }
}

// MARK: Database

extension EnumProperty: AnyDatabaseProperty {
    public var keys: [FieldKey] {
        self.field.keys
    }

    public func input(to input: DatabaseInput) {
        self.field.input(to: input)
    }

    public func output(from output: DatabaseOutput) throws {
        try self.field.output(from: output)
    }
}

// MARK: Codable

extension EnumProperty: AnyCodableProperty {
    public func encode(to encoder: Encoder) throws {
        try self.field.encode(to: encoder)
    }

    public func decode(from decoder: Decoder) throws {
        try self.field.decode(from: decoder)
    }
}