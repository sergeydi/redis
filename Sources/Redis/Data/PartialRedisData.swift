/// Reference wrapper for `RedisData` being mutated
/// by the Redis data coders.
final class PartialRedisData {
    /// The partial data.
    var data: RedisData

    /// Creates a new `PartialRedisData`.
    init(data: RedisData) {
        self.data = data
    }

    /// Sets the `RedisData` at supplied coding path.
    func set(_ data: RedisData, at path: [CodingKey]) {
        set(&self.data, to: data, at: path)
    }

    /// Returns the value, if one at from the given path.
    func get(at path: [CodingKey]) -> RedisData? {
        var child = data
        for seg in path {
            switch child.storage {
            case .array(let arr):
                guard let index = seg.intValue, arr.count > index else {
                    return nil
                }
                child = arr[index]
            default:
                return nil
            }
        }
        return child
    }

    /// Sets the mutable `RedisData` to supplied data at coding path.
    private func set(_ context: inout RedisData, to value: RedisData, at path: [CodingKey]) {
        guard path.count >= 1 else {
            context = value
            return
        }

        let end = path[0]

        var child: RedisData?
        switch path.count {
        case 1:
            child = value
        case 2...:
            if let index = end.intValue {
                let array = context.array ?? []
                if array.count > index {
                    child = array[index]
                } else {
                    child = RedisData.array([])
                }
                set(&child!, to: value, at: Array(path[1...]))
            }
        default: break
        }

        if let index = end.intValue {
            if case .array(var arr) = context.storage {
                if arr.count > index {
                    arr[index] = child ?? .null
                } else {
                    arr.append(child ?? .null)
                }
                context = .array(arr)
            } else if let child = child {
                context = .array([child])
            }
        }
    }
}


/// MARK: Encoding Convenience

extension PartialRedisData {
    /// Sets a generic fixed width integer to the supplied path.
    func setFixedWidthInteger<U>(_ value: U, at path: [CodingKey]) throws
        where U: FixedWidthInteger
    {
        try set(.integer(safeCast(value, at: path)), at: path)
    }

    /// Sets an encodable value at the supplied path.
    func setEncodable<E>(_ value: E, at path: [CodingKey]) throws where E: Encodable {
        let encoder = _RedisDataEncoder(partialData: self, at: path)
        try value.encode(to: encoder)
    }
}

/// MARK: Decoding Convenience

extension PartialRedisData {
    /// Gets a value at the supplied path or throws a decoding error.
    func requireGet<T>(_ type: T.Type, at path: [CodingKey]) throws -> RedisData {
        switch get(at: path) {
        case .some(let w): return w
        case .none: throw DecodingError.valueNotFound(T.self, .init(codingPath: path, debugDescription: ""))
        }
    }

    /// Gets a decodable value at the supplied path.
    func requireDecodable<D>(_ value: D.Type = D.self, at path: [CodingKey]) throws -> D
        where D: Decodable
    {
        let decoder = _RedisDataDecoder(partialData: self, at: path)
        return try D(from: decoder)
    }

    /// Gets a `Float` from the supplied path or throws a decoding error.
    func requireFixedWidthItenger<I>(_ type: I.Type = I.self, at path: [CodingKey]) throws -> I
        where I: FixedWidthInteger
    {
        switch try requireGet(I.self, at: path).storage {
        case .integer(let value): return try safeCast(value, at: path)
        default: throw DecodingError.typeMismatch(type, .init(codingPath: path, debugDescription: ""))
        }
    }

    /// Safely casts one `FixedWidthInteger` to another.
    private func safeCast<I, V>(_ value: V, at path: [CodingKey], to type: I.Type = I.self) throws -> I where V: FixedWidthInteger, I: FixedWidthInteger {
        if let existing = value as? I {
            return existing
        }

        guard I.bitWidth >= V.bitWidth else {
            throw DecodingError.typeMismatch(type, .init(codingPath: path, debugDescription: "Bit width too wide: \(I.bitWidth) < \(V.bitWidth)"))
        }
        guard value <= I.max else {
            throw DecodingError.typeMismatch(type, .init(codingPath: path, debugDescription: "Value too large: \(value) > \(I.max)"))
        }
        guard value >= I.min else {
            throw DecodingError.typeMismatch(type, .init(codingPath: path, debugDescription: "Value too small: \(value) < \(I.min)"))
        }
        return I(value)
    }

    /// Gets a `FloatingPoint` from the supplied path or throws a decoding error.
    func requireFloatingPoint<F>(_ type: F.Type = F.self, at path: [CodingKey]) throws -> F
        where F: BinaryFloatingPoint
    {
        switch try requireGet(F.self, at: path).storage {
        case .integer(let value): return F(value)
        default: throw DecodingError.typeMismatch(F.self, .init(codingPath: path, debugDescription: ""))
        }
    }

    /// Gets a `String` from the supplied path or throws a decoding error.
    func requireString(at path: [CodingKey]) throws -> String {
        switch try requireGet(String.self, at: path).storage {
        case .basicString(let value): return value
        default: throw DecodingError.typeMismatch(String.self, .init(codingPath: path, debugDescription: ""))
        }
    }

    /// Gets a `Bool` from the supplied path or throws a decoding error.
    func requireBool(at path: [CodingKey]) throws -> Bool {
        switch try requireGet(Bool.self, at: path).storage {
        case .integer(let value): return value == 1
        default: throw DecodingError.typeMismatch(Bool.self, .init(codingPath: path, debugDescription: ""))
        }
    }
}
