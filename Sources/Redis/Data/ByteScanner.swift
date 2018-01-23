import Bits

struct ByteScanner {
    private var buffer: ByteBuffer
    private var offset: Int

    var count: Int {
        return buffer.count - offset
    }

    init(_ buffer: ByteBuffer) {
        self.buffer = buffer
        self.offset = 0
    }

    mutating func pop() -> Byte? {
        defer { offset += 1 }
        return peek()
    }

    mutating func peek() -> Byte? {
        guard count > 0 else {
            return nil
        }
        return self[0]
    }

    mutating func skip(count: Int) {
        offset += count
    }

    mutating func requirePop() throws -> Byte {
        guard let pop = self.pop() else {
            fatalError() // FIXME
        }
        return pop
    }

    mutating func consume(count: Int) -> ByteBuffer? {
        guard count <= self.count else {
            return nil
        }

        defer { offset += count }
        return ByteBuffer(
            start: buffer.baseAddress?.advanced(by: offset),
            count: count
        )
    }

    mutating func requireConsume(count: Int) throws -> ByteBuffer {
        guard let buffer = consume(count: count) else {
            fatalError()
        }
        return buffer
    }

    subscript(_ index: Int) -> Byte {
        return buffer[offset + index]
    }
}

extension ByteScanner: CustomStringConvertible {
    /// See `CustomStringConvertible.description`
    var description: String {
        var string = "0x"
        if offset != 0 {
            string.append(" ")
        }
        for i in 0..<buffer.count {
            if i == offset {
                string.append("•")
            }

            let byte = buffer[i]
            let upper = Int(byte >> 4)
            let lower = Int(byte & 0b00001111)
            string.append(map[upper])
            string.append(map[lower])
            if i + 1 != offset {
                string.append(" ")
            }
        }

        if offset == buffer.count {
            string.append("•")
        }
        return string
    }
}

let map = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F"]
