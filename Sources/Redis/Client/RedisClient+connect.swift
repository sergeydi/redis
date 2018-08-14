import Async
import NIO

extension RedisClient {
    /// Connects to a Redis server using a TCP socket.
    public static func connect(
        hostname: String = "localhost",
        port: Int = 6379,
        password: String? = nil,
        on worker: Worker,
        onError: @escaping (Error) -> Void
    ) -> Future<RedisClient> {
        let handler = RedisConnectionHandler()
        let bootstrap = ClientBootstrap(group: worker.eventLoop)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                return channel.pipeline.addRedisHandlers().then {
                    channel.pipeline.add(handler: handler)
                }
            }
        return bootstrap.connect(host: hostname, port: port).map { channel -> RedisClient in
            let client = RedisClient(channel: channel)
            handler.delegate = client
            return client
        }.flatMap { client -> Future<RedisClient> in
            if let password = password {
                return client.authorize(with: password)
                    .transform(to: client)
            } else {
                return worker.future(client)
            }
        }
    }
}

private extension ChannelPipeline {
    func addRedisHandlers(first: Bool = false) -> EventLoopFuture<Void> {
        return addHandlers(RedisDataEncoder(), RedisDataDecoder(), first: first)
    }
}
