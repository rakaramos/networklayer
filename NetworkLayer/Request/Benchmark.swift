import Foundation

struct Benchmark {
    private var timer = Timer()
    private var tickTimer = Timer()
    private var ticks = [Double]()
    
    var average: Double {
        get {
            return ticks.reduce(0, combine: +)/Double(ticks.count)
        }
    }
    
    mutating func start() {
        timer.start()
        tickTimer.start()
    }

    mutating func stop() {
        timer.stop()
        tickTimer.stop()
    }
    
    mutating func tick(totalData: NSData, feshData: NSData) {
        tickTimer.stop()
        let delta = totalData.sizeInBytes - feshData.sizeInBytes
        let tickBandwidth = delta/tickTimer.seconds
        ticks.append(tickBandwidth)
        tickTimer.start()
    }
    
    func bandwidth(data: NSData) -> Double {
        return calculateBandwith(data)
    }
    
    private func calculateBandwith(data: NSData) -> Double {
        return data.sizeInBytes/timer.seconds
    }
}