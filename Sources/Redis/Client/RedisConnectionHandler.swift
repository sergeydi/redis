internal final class RedisConnectionHandler: ChannelInboundHandler {
    typealias InboundIn = RedisData
    
    var delegate: RedisConnectionDelegate?
    
    init() { }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let redisData = unwrapInboundIn(data)
        guard let delegate = self.delegate else {
            fatalError("No RedisConnectionDelegate set to handle: \(redisData).")
        }
        delegate.redisHandle(redisData)
    }
    
    func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        guard let delegate = self.delegate else {
            fatalError("No RedisConnectionDelegate set to handle: \(error).")
        }
        delegate.redisHandle(error)
    }
}

internal protocol RedisConnectionDelegate {
    func redisHandle(_ redisData: RedisData) -> Void
    func redisHandle(_ error: Error) -> Void
}
