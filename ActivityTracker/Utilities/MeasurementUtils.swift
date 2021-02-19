//
//  MeasurementUtils.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 12/22/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import Foundation

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
    
    //MARK: imperial
    //TODO when I feel like looking up conversions shouldn't be long
    
    
}
