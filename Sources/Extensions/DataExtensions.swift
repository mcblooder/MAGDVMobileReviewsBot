import AsyncHTTPClient
import NIOCore
import Foundation

extension Data {
    
    /// Creates a `Data` from a given `ByteBuffer`. The entire readable portion of the buffer will be read.
    /// - parameter buffer: The buffer to read.
    static func from(buffer: ByteBuffer) -> Data {
        let bytes = buffer.getBytes(at: 0, length: buffer.readableBytes) ?? []
        return Data.init(bytes: bytes, count: bytes.count)
    }
    
}