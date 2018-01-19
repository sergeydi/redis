/// Internal `UnkeyedEncodingContainer` for `RedisDataEncoder`.
internal final class RedisDataUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    /// See `UnkeyedEncodingContainer.count`
    var count: Int

    /// See `KeyedEncodingContainerProtocol.codingPath`
    var codingPath: [CodingKey]

    /// Data being encoded.
    let partialData: PartialRedisData

    /// Creates a coding key for the current index, then increments the count.
    var index: CodingKey {
        defer { count += 1 }
        return RedisDataArrayKey(count)
    }

    /// Creates a new `RedisDataKeyedEncodingContainer`
    init(partialData: PartialRedisData, at path: [CodingKey]) {
        self.codingPath = path
        self.partialData = partialData
        self.count = 0
    }

    /// See `UnkeyedEncodingContainer.encodeNil`
    func encodeNil() throws {
        partialData.set(.null, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Bool) throws {
        partialData.set(.integer(value ? 1 : 0), at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Int) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Int8) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Int16) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Int32) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Int64) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: UInt) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: UInt8) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: UInt16) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: UInt32) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: UInt64) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Float) throws {
        partialData.set(.basicString(value.description), at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: Double) throws {
        partialData.set(.basicString(value.description), at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode(_ value: String) throws {
        partialData.set(.basicString(value), at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.encode`
    func encode<T>(_ value: T) throws where T : Encodable {
        try partialData.setEncodable(value, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.nestedContainer`
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        fatalError(RedisError(identifier: "keyedEncoder", reason: "Keyed encoder not supported.").description)
    }

    /// See `UnkeyedEncodingContainer.nestedUnkeyedContainer`
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return RedisDataUnkeyedEncodingContainer(partialData: partialData, at: codingPath + [index])
    }

    /// See `UnkeyedEncodingContainer.superEncoder`
    func superEncoder() -> Encoder {
        return _RedisDataEncoder(partialData: partialData, at: codingPath + [index])
    }
}
