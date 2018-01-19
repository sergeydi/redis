///// Internal `KeyedEncodingContainerProtocol` for `RedisDataEncoder`.
//internal final class RedisDataKeyedEncodingContainer<K>: KeyedEncodingContainerProtocol
//    where K: CodingKey
//{
//    /// See `KeyedEncodingContainerProtocol.codingPath`
//    var codingPath: [CodingKey]
//
//    /// Data being encoded.
//    let partialData: PartialRedisData
//
//    /// Creates a new `RedisDataKeyedEncodingContainer`
//    init(partialData: PartialRedisData, at path: [CodingKey]) {
//        self.codingPath = path
//        self.partialData = partialData
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encodeNil`
//    func encodeNil(forKey key: K) throws {
//        partialData.set(.null, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Bool, forKey key: K) throws {
//        partialData.set(.integer(value ? 1 : 0), at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Int, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Int8, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Int16, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Int32, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Int64, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: UInt, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: UInt8, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: UInt16, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: UInt32, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: UInt64, forKey key: K) throws {
//        try partialData.setFixedWidthInteger(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Float, forKey key: K) throws {
//        partialData.set(.basicString(value.description), at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: Double, forKey key: K) throws {
//        partialData.set(.basicString(value.description), at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode(_ value: String, forKey key: K) throws {
//        partialData.set(.basicString(value), at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.encode`
//    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
//        try partialData.setEncodable(value, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.nestedContainer`
//    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
//        where NestedKey: CodingKey
//    {
//        let container = RedisDataKeyedEncodingContainer<NestedKey>(partialData: partialData, at: codingPath + [key])
//        return .init(container)
//    }
//
//    /// See `KeyedEncodingContainerProtocol.nestedUnkeyedContainer`
//    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
//        return RedisDataUnkeyedEncodingContainer(partialData: partialData, at: codingPath + [key])
//    }
//
//    /// See `KeyedEncodingContainerProtocol.superEncoder`
//    func superEncoder() -> Encoder {
//        return _RedisDataEncoder(partialData: partialData, at: codingPath)
//    }
//
//    /// See `KeyedEncodingContainerProtocol.superEncoder`
//    func superEncoder(forKey key: K) -> Encoder {
//        return _RedisDataEncoder(partialData: partialData, at: codingPath + [key])
//    }
//}

