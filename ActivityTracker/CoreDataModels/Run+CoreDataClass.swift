//
//  Run+CoreDataClass.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/7/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData
import os.log

@objc(Run)
public class Run: Activity {

    /**
            calculates the minimum and maximum elevation for this run
     */
    public func psuedoinit(){
        self.calcMinMaxElevation()
        self.calcAveragePace()
    }
    //maybe move to MeasurementUtils
    private func calcMinMaxElevation(){
        //checks for a nonempty path
        if self.path == nil || self.path.count == 0{
            os_log("not enough points", type: .debug)
            //maybe make nil
            self.minElevation = 0
            self.maxElevation = 0
            return
        }
        var currentMin = path[0].altitude
        var currentMax = path[0].altitude
        
        for i in 0..<path.count{
            let nextElevation = path[i].altitude
            currentMin = min(currentMin, nextElevation)
            currentMax = max(currentMax, nextElevation)
        }
    }
    
    /*
     calculate the average pace in seconds/km
     */
    private func calcAveragePace(){
        let seconds = MeasurementUtils.millisecondsToSeconds(ms: self.time)
        let km = MeasurementUtils.metersToKilometers(m: self.distance)
        self.averagePace = seconds/km
    }
}
