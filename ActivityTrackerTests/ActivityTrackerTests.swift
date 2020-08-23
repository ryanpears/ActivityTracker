//
//  ActivityTrackerTests.swift
//  ActivityTrackerTests
//
//  Created by Ryan Pearson on 7/29/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import XCTest
import CoreLocation
@testable import ActivityTracker

class ActivityTrackerTests: XCTestCase {
    
    //MARK: Activity Tests
    //so testing this is going to absolutely suck
    func testActivityInit(){
        var path:[PosTime] = []
        path.append(PosTime.init(time:0, possition: CLLocation(latitude:  44.098681, longitude: -114.955616))!)
        path.append(PosTime.init(time: 1840, possition: CLLocation(latitude:  44.0842558, longitude: -114.9731255))!)
        path.append(PosTime.init(time: 3443, possition: CLLocation(latitude:  44.0747604, longitude: -114.9897766))!)
        path.append(PosTime.init(time:4575, possition: CLLocation(latitude:  44.067977, longitude: -115.0050545))!)
        path.append(PosTime.init(time: 6000, possition:CLLocation(latitude:  44.0549014, longitude: -115.0131226))!)
        let act1 = Activity.init(path: path)
        var distance:Double = 0
        for i in 1..<path.count{
            let coord1 = path[i-1].pos
            let coord2 = path[i].pos
            distance += coord1.distance(from: coord2)
        }
        let avePace = 6000/distance

        XCTAssertNotNil(act1)
        XCTAssertEqual(act1.distance, distance )//tests that the distance is calculated to within a meter which is a bit more realistic then 1e-9
        XCTAssertTrue(act1.time - 6000 < 1e-9)
        //XCTAssertTrue(act1.avePace - avePace < 1e-7)
        XCTAssertEqual(avePace, act1.avePace)
    }
    
    func testUnchangingCoordinateDistance(){
        //write test with coordinates varying by less than a meter to make sure they aren't logged in distance
        var path:[PosTime] = []
        path.append(PosTime(time: 0, possition: CLLocation(latitude: 55.000000000023, longitude: 55.000000000023))!)
        path.append(PosTime(time: 0, possition: CLLocation(latitude: 55.000000000022, longitude: 55.000000000023))!)
        let act = Activity(path: path)
        XCTAssertTrue(act.distance == 0)
    }
    
    func testSmallChangePath(){
        //write a test that with small distance changes to make sure it will calculate the correct distance
    }
    func testTooSmallPathInits(){
        var path:[PosTime] = []
        let act1 = Activity(path: path)
        XCTAssertNotNil(act1)
        XCTAssertTrue(act1.distance == 0)
        XCTAssertTrue(act1.time == 0)
        XCTAssertTrue(act1.avePace == 0)
        
        path.append(PosTime(time: 0, possition: CLLocation(latitude: 55.000000000023, longitude: 55.000000000023))!)
        let act2 = Activity(path: path)
        XCTAssertNotNil(act2)
        XCTAssertTrue(act2.distance == 0)
        XCTAssertTrue(act2.time == 0)
        XCTAssertTrue(act2.avePace == 0)
               
    }
    //MARK:PosTime Tests
    func testPosTimeInit(){
        let pt1 = PosTime.init(time: 5.0, possition: CLLocation.init())
        XCTAssertNotNil(pt1)
        let pt2 = PosTime.init(time: 0, possition: CLLocation.init(latitude: CLLocationDegrees(124.9), longitude: CLLocationDegrees(45.0004)))
        XCTAssertNotNil(pt2)
    }
    
    func testPosTimeInitFail(){
        let pt1 = PosTime.init(time: -90.3, possition: CLLocation.init())
        XCTAssertNil(pt1)
    }
    
    func testPosTimeNonStatic(){
        let pt1 = PosTime.init(time: 7.82, possition: CLLocation.init())
        let pt2 = PosTime.init(time: 0, possition: CLLocation.init(latitude: CLLocationDegrees(113.9), longitude: CLLocationDegrees(45.064)))
        XCTAssertNotEqual(pt1?.time, pt2?.time)
        XCTAssertNotEqual(pt1?.pos, pt2?.pos)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    

}
