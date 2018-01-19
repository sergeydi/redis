/// Encodes `Encodable` items to `RedisData`.
public final class RedisDataEncoder {
    /// Creates a new `RedisDataEncoder`.
    public init() {}

    /// Encodes the supplied `Encodable` to `RedisData`
    public func encode(_ encodable: Encodable) throws -> RedisData {
        let data = PartialRedisData(data: .null)
        let encoder = _RedisDataEncoder(partialData: data, at: [])
        try encodable.encode(to: encoder)
        return data.data
    }
}

/// Internal `Encoder` implementation for `RedisDataEncoder`.
internal final class _RedisDataEncoder: Encoder {
    /// See `Encoder.codingPath`
    var codingPath: [CodingKey]

    /// See `Encoder.codingPath`
    var userInfo: [CodingUserInfoKey: Any]

    /// Data being encoded.
    let partialData: PartialRedisData

    /// Creates a new internal `_RedisDataEncoder`.
    init(partialData: PartialRedisData, at path: [CodingKey]) {
        self.codingPath = path
        self.userInfo = [:]
        self.partialData = partialData
    }

    /// See `Encoder.container`
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        /// FIXME: any way around this?
        fatalError(RedisError(identifier: "keyedEncoder", reason: "Keyed encoder not supported.").description)
    }

    /// See `Encoder.unkeyedContainer`
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return RedisDataUnkeyedEncodingContainer(partialData: partialData, at: codingPath)
    }

    /// See `Encoder.singleValueContainer`
    func singleValueContainer() -> SingleValueEncodingContainer {
        return RedisDataSingleValueEncodingContainer(partialData: partialData, at: codingPath)
    }
}
