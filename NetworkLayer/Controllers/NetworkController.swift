import Foundation

public class NetworkController: NSObject {
    
    private let queue = NSOperationQueue()
    private let kvoFinishedKeypath  = "isFinished"
    private var kvoContext: UInt8   = 10
    private var networkMetrics      = [Double]()
    private var bandwidthScales: BandwidthScales?
    private var currentScale: NetworkQuality? {
        didSet(newValue) {
            guard let scale = newValue else { return }
            balanceQueue(scale)
        }
    }
    
    convenience public init(scales: BandwidthScales) {
        self.init()
        bandwidthScales = scales
    }
    
    deinit {
        removeObservers()
    }
    
    public func fetchRequest(request: BaseRequest) {
        observeRequest(request)
        queue.addOperation(request)
    }
    
    // MARK: Operations KVO
    
    private func observeRequest(request: BaseRequest) {
        request.addObserver(self, forKeyPath: kvoFinishedKeypath, options: .New, context: &kvoContext)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let request = object as? BaseRequest where context == &kvoContext else { return }
        switch keyPath {
        case .Some(let value) where value == kvoFinishedKeypath:
            let bandwidth = request.bandwidth
            currentScale = bandwidthScales?.qualityForBandwidth(bandwidth)
            networkMetrics.append(bandwidth)
            removeObserver(request)
            if (request.cancelled) {
                print(String(format: ":( Canceled %.3fKb/s :: Network is \(currentScale) \(request.name)", bandwidth))
            } else {
                print(String(format: ":) Finished %.3fKb/s  Average %.3fKb/s :: Network is \(currentScale) \(request.name)", bandwidth, request.average))
            }
        default:
            break
        }
    }
    
    private func removeObserver(request: BaseRequest?) {
        request?.removeObserver(self, forKeyPath: kvoFinishedKeypath, context: &kvoContext)
    }
    
    private func removeObservers() {
        queue.operations.forEach { operation in
            removeObserver(operation as? BaseRequest)
        }
    }
    
    private func balanceQueue(quality: NetworkQuality) {
        guard let priority = bandwidthScales?.operationQualityForNetworkQuality(quality) else { return }
        cancelRequestLowerThan(priority)
    }
    
    // MARK: Cancelation
    
    private func cancelRequestLowerThan(priority: NSOperationQueuePriority) {
        queue.operations
         .filter { operation in
            return operation.queuePriority.rawValue < priority.rawValue
        }.forEach { operation in
            operation.cancel()
        }
    }
}