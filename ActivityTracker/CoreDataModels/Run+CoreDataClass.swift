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
    override func psuedoinit(path: [CLLocation]){
        super.psuedoinit(path: path)
        let minMax = MeasurementUtils.calcMinMaxElevation(path: path)
        self.minElevation = minMax.min
        self.maxElevation = minMax.max
        self.calcAveragePace()
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
