import Async
import Dispatch
@testable import Redis
import TCP
import XCTest

class RedisTests: XCTestCase {
    func testParser() throws {
        let parserStream = RedisDataParser().stream()

        let socket = PushStream(String.self)
        socket.map(to: ByteScanner.self) { string in
            let data =  string.data(using: .utf8)!
            return ByteScanner(data.withByteBuffer { $0 })
        }
        .stream(to: parserStream)
        .drain { data in
            print(data)
        }.catch { error in
            XCTFail("\(error)")
        }.finally {
            print("closed")
        }

        let simpleString = "+OK\r\n+OK\r\n+Hello, world!\r\n"
        socket.push(simpleString)
    }

    func testCRUD() throws {
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.crud")
        let redis = try RedisClient.connect(on: eventLoop)
        try redis.set("world", forKey: "hello").await(on: eventLoop)
        let get = try redis.get(String.self, forKey: "hello").await(on: eventLoop)
        XCTAssertEqual(get, "world")
        try redis.remove("hello").await(on: eventLoop)
    }

    func testPubSub() throws {
        // Setup
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.pubsub")
        let promise = Promise(RedisData.self)

        // Subscribe
        try RedisClient.subscribe(to: ["foo"], on: eventLoop).await(on: eventLoop).drain { data in
            XCTAssertEqual(data.channel, "foo")
            promise.complete(data.data)
        }.catch { error in
            XCTFail("\(error)")
        }.finally {
            print("closed")
        }

        // Publish
        let publisher = try RedisClient.connect(on: eventLoop)
        let publish = try publisher.publish(.bulkString("it worked"), to: "foo").await(on: eventLoop)
        XCTAssertEqual(publish.int, 1)

        // Verify
        let data = try promise.future.await(on: eventLoop)
        XCTAssertEqual(data.string, "it worked")
    }

    func testStruct() throws {
        struct Hello: Codable {
            var message: String
            var array: [Int]
            var dict: [String: Bool]
        }
        let hello = Hello(message: "world", array: [1, 2, 3], dict: ["yes": true, "false": false])
        let eventLoop = try DefaultEventLoop(label: "codes.vapor.redis.test.struct")
        let redis = try RedisClient.connect(on: eventLoop)
        try redis.set(hello, forKey: "hello").await(on: eventLoop)
        let get = try redis.get(Hello.self, forKey: "hello").await(on: eventLoop)
        XCTAssertEqual(get?.message, "world")
        XCTAssertEqual(get?.array.first, 1)
        XCTAssertEqual(get?.array.last, 3)
        XCTAssertEqual(get?.dict["yes"], true)
        XCTAssertEqual(get?.dict["false"], false)
        try redis.remove("hello").await(on: eventLoop)

    }

    static let allTests = [
        ("testCRUD", testCRUD),
        ("testPubSub", testPubSub),
        ("testStruct", testStruct),
    ]
}
