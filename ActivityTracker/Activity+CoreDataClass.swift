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
        self.time = path[path.count-1].timestamp.timeIntervalSince(path[0].timestamp)
    }
    
}