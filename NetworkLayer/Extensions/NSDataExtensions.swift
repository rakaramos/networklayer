import Foundation

public extension NSData {
    public var sizeInBytes: Double {
        return Double(length)/1024
    }
}