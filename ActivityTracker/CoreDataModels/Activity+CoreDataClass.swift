//
//  Activity+CoreDataClass.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 1/27/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData
import os.log

@objc(Activity)
public class Activity: NSManagedObject {

    //NOTE: feild varibles should be in Activity+CoreDataProperties
    
    /**
        A "init" function that should be called immediately after the insertion of a new Activity into coredata
        Reasoning for this:
            Due to CoreData constraints an NSManagedObject must be inserted into a context then populated with data
        At least as far as I can tell.
     */
    func psuedoinit(path: [CLLocation]){
        
        self.path = path
        self.calcDistance()
        self.calcTime()
        self.calcElevationGain()
    }
    
    
    //MARK: private methods
    private func calcDistance(){
        if path.count < 2 {
            os_log("not enough points in path to calculate distance", type: .debug)
            self.distance = 0.0
            return
        }
        //possibly move to measurementUtils
        var dist:Double = 0
        var prevLocation: CLLocation = path[0]
        for i in 1..<path.count{
            let nextLocation:CLLocation = path[i]
            let calcDist = prevLocation.distance(from: nextLocation)
            //only add if the calculated distance is greater then the horizontal accuraty
    
            if calcDist > nextLocation.horizontalAccuracy {
                prevLocation = nextLocation
                dist += calcDist
            }
        }
        self.distance = dist
        
    }
    
    private func calcTime(){
        if path.isEmpty{
            os_log("I honestly dont think this can happen but it feels wrong not doing this", type: .debug)
            self.time = 0.0
            return
        }
        //really hope this is ok
        //calculates time between last recorded possitions
        let firstLocation = path[0]
        let lastLocation = path[path.count-1]

        self.time = lastLocation.timestamp.timeIntervalSince(firstLocation.timestamp)
        print("THE TIME IS :", self.time)
    }
    
    private func calcElevationGain(){
        if path.count < 2 {
            os_log("not enough points in path to calculate elevation", type: .debug)
            self.elevationGain = 0.0
            return
        }
        //possibly move to measurementUtils
        var elevation:Double = 0
        var prevLocation: CLLocation = path[0]
        var prevElevation = prevLocation.altitude
        
        for i in 1..<path.count{
            let nextLocation:CLLocation = path[i]
            let nextElevation = nextLocation.altitude
            let calcElevation = nextElevation - prevElevation
            //only add if the elevation is greater then vertical accuraty and possitive
            if calcElevation > 0 && calcElevation > nextLocation.verticalAccuracy{
                elevation += calcElevation
                prevLocation = nextLocation
                prevElevation = nextElevation
            }else if calcElevation < 0 && abs(calcElevation) > nextLocation.verticalAccuracy{
                //if the elevation is dropping update starting location not gain
                prevLocation = nextLocation
                prevElevation = nextElevation
            }
        }
        self.elevationGain = elevation
    }
    
}
