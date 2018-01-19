/// Internal `UnkeyedDecodingContainer` for `RedisDataDecoder`
final class RedisDataUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    /// See `UnkeyedDecodingContainer.count`
    var count: Int?

    /// See `UnkeyedDecodingContainer.isAtEnd`
    var isAtEnd: Bool {
        return currentIndex == count
    }

    /// See `UnkeyedDecodingContainer.currentIndex`
    var currentIndex: Int

    /// Creates a coding key for the current index, then increments the count.
    var index: CodingKey {
        defer { currentIndex += 1}
        return RedisDataArrayKey(currentIndex)
    }

    /// See `UnkeyedDecodingContainer.codingPath`
    var codingPath: [CodingKey]

    /// Data being encoded.
    let partialData: PartialRedisData

    /// Creates a new internal `RedisDataUnkeyedDecodingContainer`.
    init(partialData: PartialRedisData, at path: [CodingKey]) {
        self.codingPath = path
        self.partialData = partialData
        switch partialData.get(at: codingPath)?.storage {
        case .some(let w):
            switch w {
            case .array(let a): count = a.count
            default: count = nil
            }
        case .none: count = nil
        }
        currentIndex = 0
    }

    /// See `UnkeyedDecodingContainer.decodeNil`
    func decodeNil() throws -> Bool {
        return partialData.get(at: codingPath + [index]) == nil
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Bool.Type) throws -> Bool {
        return try partialData.requireBool(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Int.Type) throws -> Int {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Int8.Type) throws -> Int8 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Int16.Type) throws -> Int16 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Int32.Type) throws -> Int32 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Int64.Type) throws -> Int64 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: UInt.Type) throws -> UInt {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try partialData.requireFixedWidthItenger(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Float.Type) throws -> Float {
        return try partialData.requireFloatingPoint(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: Double.Type) throws -> Double {
        return try partialData.requireFloatingPoint(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode(_ type: String.Type) throws -> String {
        return try partialData.requireString(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.decode`
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try partialData.requireDecodable(at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.nestedContainer`
    func nestedContainer<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key: CodingKey
    {
        throw RedisError(identifier: "keyedDecoder", reason: "Keyed decoder not supported.")
    }

    /// See `UnkeyedDecodingContainer.nestedUnkeyedContainer`
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return RedisDataUnkeyedDecodingContainer(partialData: partialData, at: codingPath + [index])
    }

    /// See `UnkeyedDecodingContainer.superDecoder`
    func superDecoder() throws -> Decoder {
        return _RedisDataDecoder(partialData: partialData, at: codingPath + [index])
    }
}
