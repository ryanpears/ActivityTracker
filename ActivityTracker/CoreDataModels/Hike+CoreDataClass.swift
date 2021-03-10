//
//  Hike+CoreDataClass.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/9/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Hike)
public class Hike: Activity {
    
    
    override func psuedoinit(path: [CLLocation]){
        super.psuedoinit(path: path)
        let minMax = MeasurementUtils.calcMinMaxElevation(path: path)
        self.minElevation = minMax.min
        self.maxElevation = minMax.max
        self.calcAveragePace()
    }
    
    private func calcAveragePace(){
        self.averagePace = MeasurementUtils.metersPerSecondToKilometersPerHour(mps: (self.distance / self.time))
    }
    
}
