import Foundation

public class BaseRequest: NSOperation {
    
    var theURL = NSURL()
    var bandwidth: Double {
        return benchmark.bandwidth(incomingData)
    }

    private let incomingData = NSMutableData()
    private var sessionTask: NSURLSessionTask?
    private var benchmark: Benchmark = Benchmark()
    private var localURLSession: NSURLSession {
        return NSURLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
    }
    
    private var localConfig: NSURLSessionConfiguration {
        return NSURLSessionConfiguration.defaultSessionConfiguration()
    }
    
    var average: Double {
        get {
            return benchmark.average
        }
    }
    
    var innerFinished: Bool = false {
        didSet {
            if(innerFinished) {
                benchmark.stop()
            }
        }
    }
    
    override public var finished: Bool {
        get {
            return innerFinished
        }
        //Note that I am triggering a KVO notification on isFinished as opposed to finished which is what the property name is. This seems to be a Swift-ism as the NSOperation get accessor is called isFinished instead of getFinished and I suspect that is part of why I need to tickle the accessor name instead of the property name.
        set (newValue) {
            willChangeValueForKey("isFinished")
            innerFinished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    convenience public init(URL: NSURL) {
        self.init()
        self.theURL = URL
    }
    
    override public func start() {
        print("Start fetching \(theURL)")
        if cancelled {
            finished = true
            return
        }
        
        let request = NSMutableURLRequest(URL: theURL)
        sessionTask = localURLSession.dataTaskWithRequest(request)
        sessionTask?.resume()
    }
    
    func finish() {
        finished = true
        sessionTask?.cancel()
    }
}

extension BaseRequest: NSURLSessionDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print("Start downloading \(theURL) \(queuePriority.rawValue)")
        benchmark.start()
        if cancelled {
            finish()
            return
        }
        
        //Check the response code and react appropriately
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if cancelled {
            finish()
            return
        }
        incomingData.appendData(data)
        benchmark.tick(incomingData, feshData: data)
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        defer {
            finished = true
        }
        if cancelled {
            sessionTask?.cancel()
            return
        }
        if NSThread.isMainThread() { print("Main Thread!") }
        if error != nil {
            print("Failed to receive response: \(error)")
            return
        }
        //processData()
    }
}