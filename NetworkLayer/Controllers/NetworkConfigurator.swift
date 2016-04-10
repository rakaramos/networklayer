import Foundation

public enum NetworkQuality: Int {
    case VeryPoor = 0, Poor, Regular, Good, VeryGood
}

extension NetworkQuality: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .VeryPoor:
            return "Very Poor"
        case .Poor:
            return "Poor"
        case .Regular:
            return "Regular"
        case .Good:
            return "Good"
        case .VeryGood:
            return "Very Good"
        }
    }
}

public protocol BandwidthScales {
    func qualityForBandwidth(value: Double) -> NetworkQuality
    func operationQualityForNetworkQuality(networkQuality: NetworkQuality) -> NSOperationQueuePriority
}

public extension BandwidthScales {
    func qualityForBandwidth(value: Double) -> NetworkQuality {
        
        var quality: NetworkQuality = .VeryPoor
        if value >= 0 && value < 25 {
            quality = .VeryPoor
        }
        if value >= 25 && value < 50 {
            quality = .VeryPoor
        }
        if value >= 50 && value < 100 {
            quality = .VeryPoor
        }
        if value >= 100 {
            quality = .VeryPoor
        }
        
        return quality
    }
    
    func operationQualityForNetworkQuality(networkQuality: NetworkQuality) -> NSOperationQueuePriority {
        switch networkQuality {
        case .VeryPoor:
            return .VeryHigh
        case .Poor:
            return .High
        case .Regular:
            return .Normal
        case .Good:
            return .Low
        case .VeryGood:
            return .VeryLow
        }
    }
}

public struct DefaultScales: BandwidthScales {
    public init() {}
}