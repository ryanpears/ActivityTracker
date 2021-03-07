//
//  MeasurementUtils.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 12/22/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import Foundation
import CoreLocation
import os.log

//class used for conversions between measurements
class MeasurementUtils{
    
    //MARK: formating
    static func timeString(time: Double) -> String {
        //checking for valid input
        if time.isNaN || time.isInfinite {
            return String(format: "%.2d:%.2d", 0, 0)
        }
        
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let minutes = Int(time.truncatingRemainder(dividingBy: 60 * 60) / 60)
        return String(format: "%.2d:%.2d", minutes, seconds)
    }
    
    //MARK: metric
    static func millisecondsToSeconds(ms: Double) -> Double {
        return ms/1000
    }
    
    static func metersToKilometers(m: Double) -> Double{
        return m/1000
    }
    
    static func millisecondsPerMeterToKilometersPerHour(mspm: Double) -> Double{
        return mspm * 3600
    }
    /*
     returns tuple where the first value is the minimum elevation and second is maximum elevation
     */
    static func calcMinMaxElevation(path: [CLLocation]?) -> (min: Double, max: Double){
        //checks for a nonempty path
        if path == nil || path?.count == 0{
            os_log("not enough points", type: .debug)
            //maybe make nil
            return (min: 0, max: 0)
        }
        var currentMin = path![0].altitude
        var currentMax = path![0].altitude
        
        for i in 0..<path!.count{
            let nextElevation = path![i].altitude
            currentMin = min(currentMin, nextElevation)
            currentMax = max(currentMax, nextElevation)
        }
        return (min: currentMin, max: currentMax)
    }
    
    //MARK: imperial
    //TODO when I feel like looking up conversions shouldn't be long
    
    
}
