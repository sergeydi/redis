/// Encodes `Decodable` items to `RedisData`.
public final class RedisDataDecoder {
    /// Creates a new `RedisDataDecoder`.
    public init() {}

    /// Decodes the supplied `Decodable` to `RedisData`
    public func decode<D>(_ type: D.Type = D.self, from data: RedisData) throws -> D
        where D: Decodable
    {
        let decoder = _RedisDataDecoder(partialData: .init(data: data), at: [])
        return try D(from: decoder)
    }
}

/// Internal `Decoder` implementation for `RedisDataDecoder`.
internal final class _RedisDataDecoder: Decoder {
    /// See `Decoder.codingPath`
    var codingPath: [CodingKey]

    /// See `Decoder.codingPath`
    var userInfo: [CodingUserInfoKey: Any]

    /// Data being encoded.
    let partialData: PartialRedisData

    /// Creates a new internal `_RedisDataDecoder`.
    init(partialData: PartialRedisData, at path: [CodingKey]) {
        self.codingPath = path
        self.userInfo = [:]
        self.partialData = partialData
    }

    /// See `Decoder.container`
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key: CodingKey
    {
        throw RedisError(identifier: "keyedDecoder", reason: "Keyed decoder not supported.")
    }

    /// See `Decoder.unkeyedContainer`
    func unkeyedContainer() -> UnkeyedDecodingContainer {
        return RedisDataUnkeyedDecodingContainer(partialData: partialData, at: codingPath)
    }

    /// See `Decoder.singleValueContainer`
    func singleValueContainer() -> SingleValueDecodingContainer {
        return RedisDataSingleValueDecodingContainer(partialData: partialData, at: codingPath)
    }
}
