import Async
import DatabaseKit

extension RedisClient: KeyedCache {
    /// See `KeyedCache.get(_:forKey)`
    public func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?>
        where D: Decodable
    {
        /// FIXME: handle nil
        return get(forKey: key).map(to: D?.self) { data in
            return try RedisDataDecoder().decode(from: data)
        }
    }

    /// See `KeyedCache.set(_:forKey)`
    public func set(_ entity: Encodable, forKey key: String) throws -> Future<Void> {
        let data = try RedisDataEncoder().encode(entity)
        return set(data, forKey: key).transform(to: ())
    }

    /// See `KeyedCache.remove`
    public func remove(_ key: String) throws -> Future<Void> {
        return delete(keys: [key]).transform(to: ())
    }
}
