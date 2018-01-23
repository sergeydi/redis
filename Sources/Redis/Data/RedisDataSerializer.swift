import Async
import Bits
import Foundation

/// A streaming Redis value serializer
internal final class RedisDataSerializer: Async.Stream {
    /// See InputStream.Input
    typealias Input = RedisData
    
    /// See OutputStream.Output
    typealias Output = ByteBuffer

    /// Use a basic output stream to implement server output stream.
    private var downstream: AnyInputStream<ByteBuffer>?

    private var lastMessage: Data?

    /// Creates a new ValueSerializer
    init() {}
    
    /// See InputStream.input
    func input(_ event: InputEvent<RedisData>) {
        switch event {
        case .close: downstream?.close()
        case .error(let error): downstream?.error(error)
        case .next(let input, let ready):
            let data = input.serialize()
            lastMessage = data
            // FIXME: More performant serialization?
            data.withByteBuffer { buffer in
                self.downstream?.next(buffer, ready)
            }
        }
    }

    /// See OutputStream.output
    func output<S>(to inputStream: S) where S: Async.InputStream, Output == S.Input {
        downstream = AnyInputStream(inputStream)
    }
}

/// Static "fast" route for serializing `null` values
fileprivate let nullData = Data("$-1\r\n".utf8)

extension RedisData {
    /// Serializes a single value
    func serialize() -> Data {
        switch self.storage {
        case .null:
            return nullData
        case .simpleString(let string):
            return Data(("+" + string).utf8)
        case .error(let error):
            return Data(("-" + error.reason).utf8)
        case .integer(let int):
            return Data(":\(int)\r\n".utf8)
        case .bulkString(let data):
            return Data("$\(data.count)\r\n".utf8) + data + Data("\r\n".utf8)
        case .array(let values):
            var buffer = Data("*\(values.count)\r\n".utf8)
            for value in values {
                buffer.append(contentsOf: value.serialize())
            }
            buffer.append(contentsOf: Data("\r\n".utf8))
            return buffer
        }
    }
}
