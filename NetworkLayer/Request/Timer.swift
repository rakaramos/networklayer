import Darwin

struct Timer {
    private var base: UInt64 = 0
    private var startTime: UInt64 = 0
    private var stopTime: UInt64 = 0
    
    init() {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        base = UInt64(info.numer / info.denom)
    }
    
    mutating func start() {
        startTime = mach_absolute_time()
    }
    
    mutating func stop() {
        stopTime = mach_absolute_time()
    }
    
    var nanoseconds: UInt64 {
        return stopTime - startTime * base
    }
    
    var milliseconds: Double {
        return Double(nanoseconds) / 1_000_000
    }
    
    var seconds: Double {
        return Double(nanoseconds) / 1_000_000_000
    }
}