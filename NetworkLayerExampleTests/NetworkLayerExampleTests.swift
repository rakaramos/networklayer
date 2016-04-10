//
//  NetworkLayerExampleTests.swift
//  NetworkLayerExampleTests
//
//  Created by Mateusz Matoszko on 10.04.2016.
//  Copyright © 2016 NSHint. All rights reserved.
//

import XCTest
@testable import NetworkLayerExample

class NetworkLayerExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBandwidthPriorities() {
        let scales = DefaultScales()
        let controller = NetworkController(scales: scales)
        
        controller.successCallback = { request in
            let bandwidth = request.bandwidth
            let networkQuality = scales.qualityForBandwidth(bandwidth)
            print(String(format: ":) Finished %.3fKb/s  Average %.3fKb/s :: Network is \(networkQuality) \(request.name)", bandwidth, request.average))
        }
        controller.failureCallback = { request in
            let bandwidth = request.bandwidth
            let networkQuality = scales.qualityForBandwidth(bandwidth)
            print(String(format: ":( Canceled %.3fKb/s :: Network is \(networkQuality) \(request.name)", bandwidth))
        }
        
        veryLow(controller)
        low(controller)
        normal(controller)
        high(controller)
        veryHigh(controller)
    }
    
    func veryLow(networkController: NetworkController) {
        let veryLow  = BaseRequest(URL: NSURL(string: "http://ipv4.download.thinkbroadband.com/100MB.zip")!)
        veryLow.name = "Very Low"
        veryLow.queuePriority = .VeryLow
        networkController.fetchRequest(veryLow)
    }
    
    func low(networkController: NetworkController) {
        let low = BaseRequest(URL: NSURL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!)
        low.name = "Low"
        low.queuePriority = .Low
        networkController.fetchRequest(low)
    }
    
    func normal(networkController: NetworkController) {
        let normal = BaseRequest(URL: NSURL(string: "http://ipv4.download.thinkbroadband.com/20MB.zip")!)
        normal.name = "Normal"
        normal.queuePriority = .Normal
        networkController.fetchRequest(normal)
    }
    
    func high(networkController: NetworkController) {
        let high = BaseRequest(URL: NSURL(string: "http://ipv4.download.thinkbroadband.com/10MB.zip")!)
        high.name = "High"
        high.queuePriority = .High
        networkController.fetchRequest(high)
    }
    
    func veryHigh(networkController: NetworkController) {
        let veryHigh = BaseRequest(URL: NSURL(string: "http://ipv4.download.thinkbroadband.com/1MB.zip")!)
        veryHigh.name = "Very High"
        veryHigh.queuePriority = .VeryHigh
        networkController.fetchRequest(veryHigh)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
