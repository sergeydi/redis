/// Internal `SingleValueEncodingContainer` for `RedisDataEncoder`.
internal final class RedisDataSingleValueEncodingContainer: SingleValueEncodingContainer {
    /// See `KeyedEncodingContainerProtocol.codingPath`
    var codingPath: [CodingKey]

    /// Data being encoded.
    let partialData: PartialRedisData

    /// Creates a new `RedisDataKeyedEncodingContainer`
    init(partialData: PartialRedisData, at path: [CodingKey]) {
        self.codingPath = path
        self.partialData = partialData
    }

    /// See `SingleValueEncodingContainer.encodeNil`
    func encodeNil() throws {
        partialData.set(.null, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Bool) throws {
        partialData.set(.integer(value ? 1 : 0), at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int8) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int16) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int32) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Int64) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt8) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt16) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt32) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: UInt64) throws {
        try partialData.setFixedWidthInteger(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Float) throws {
        partialData.set(.basicString(value.description), at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: Double) throws {
        partialData.set(.basicString(value.description), at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode(_ value: String) throws {
        partialData.set(.basicString(value), at: codingPath)
    }

    /// See `SingleValueEncodingContainer.encode`
    func encode<T>(_ value: T) throws where T : Encodable {
        try partialData.setEncodable(value, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.nestedContainer`
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) throws -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        throw RedisError(identifier: "keyedEncoder", reason: "Keyed encoder not supported.")
    }

    /// See `SingleValueEncodingContainer.nestedSingleValueContainer`
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return RedisDataUnkeyedEncodingContainer(partialData: partialData, at: codingPath)
    }

    /// See `SingleValueEncodingContainer.superEncoder`
    func superEncoder() -> Encoder {
        return _RedisDataEncoder(partialData: partialData, at: codingPath)
    }
}
