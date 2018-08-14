import NIO

/// A Redis client.
public final class RedisClient: DatabaseConnection, BasicWorker, RedisConnectionDelegate {
    public typealias Database = RedisDatabase
    
    /// See `BasicWorker`.
    public var eventLoop: EventLoop {
        return channel.eventLoop
    }

    /// See `DatabaseConnection`.
    public var isClosed: Bool

    /// See `Extendable`.
    public var extend: Extend

    /// The channel
    private let channel: Channel
    
    private enum State {
        case ready
        case waiting(Promise<RedisData>)
    }
    
    private var state: State

    /// Creates a new Redis client on the provided data source and sink.
    init(channel: Channel) {
        self.channel = channel
        self.extend = [:]
        self.isClosed = false
        self.state = .ready
        channel.closeFuture.always {
            self.isClosed = true
            switch self.state {
            case .ready: break
            case .waiting(let promise): promise.fail(error: closeError)
            }
        }
    }
    
    /// See `RedisConnectionDelegate`.
    func redisHandle(_ redisData: RedisData) {
        switch state {
        case .ready: fatalError("Unexpected redis data: \(redisData).")
        case .waiting(let promise): promise.succeed(result: redisData)
        }
    }
    
    /// See `RedisConnectionDelegate`.
    func redisHandle(_ error: Error) {
        switch state {
        case .ready: fatalError("Unexpected redis error: \(error).")
        case .waiting(let promise): promise.fail(error: error)
        }
    }

    public func command(_ command: String, _ arguments: [RedisData] = []) -> Future<RedisData> {
        return send(.array([.bulkString(command)] + arguments)).map(to: RedisData.self) { res in
            // convert redis errors to a Future error
            switch res.storage {
            case .error(let error): throw error
            default: return res
            }
        }
    }

    /// Sends `RedisData` to the server.
    public func send(_ data: RedisData) -> Future<RedisData> {
        return send([data])
    }

    public func send(_ messages: [RedisData]) -> Future<RedisData> {
        // ensure the connection is not closed
        guard !isClosed else {
            return eventLoop.newFailedFuture(error: closeError)
        }
        
        // if currentSend is not nil, previous send has not completed
        guard case .ready = state else {
            fatalError("Attempting to call `send(...)` again before previous invocation has completed.")
        }

        // create a new promise and store it
        let promise = eventLoop.newPromise(RedisData.self)
        state = .waiting(promise)
        
        // always reset state when promise is completed
        promise.futureResult.always {
            self.state = .ready
        }

        // write message then flush
        for message in messages {
            channel.write(message).catch { error in
                promise.fail(error: error)
            }
        }
        channel.flush()

        // return the promise's future result
        return promise.futureResult
    }

    /// Closes this client.
    public func close() {
        self.isClosed = true
        channel.close(promise: nil)
    }
}

private let closeError = RedisError(identifier: "closed", reason: "Connection is closed.", source: .capture())

/// MARK: Config

/// Config options for a `RedisClient.
public struct RedisClientConfig: Codable {
    /// The Redis server's hostname.
    public var hostname: String

    /// The Redis server's port.
    public var port: Int

    /// The Redis server's optional password.
    public var password: String?

    /// The database to connect to automatically.
    /// If nil, the connection will use the default 0.
    public var database: Int?

    /// Create a new `RedisClientConfig`
    public init(url: URL) {
        self.hostname = url.host ?? "localhost"
        self.port = url.port ?? 6379
        self.password = url.password
        self.database = Int(url.path)
    }

    public init() {
        self.hostname = "localhost"
        self.port = 6379
    }

    internal func toURL() throws -> URL {
        let urlString: String
        let databaseSuffix: String

        if let database = database {
            databaseSuffix = "/\(database)"
        } else {
            databaseSuffix = ""
        }

        if let password = password {
            urlString = "redis://:\(password)@\(hostname)\(databaseSuffix):\(port)"
        } else {
            urlString = "redis://\(hostname)\(databaseSuffix):\(port)"
        }

        guard let url = URL(string: urlString) else {
            throw RedisError(
                identifier: "URL creation",
                reason: "Redis client config could not be transformed to url",
                source: .capture())
        }

        return url
    }
}
