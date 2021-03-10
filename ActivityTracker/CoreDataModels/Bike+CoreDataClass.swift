//
//  Bike+CoreDataClass.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 3/9/21.
//  Copyright © 2021 Ryan Pearson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Bike)
public class Bike: Activity {
    /**
           initalizes all values for a Bike Object/Entity
     */
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
    
    //hopefully works seems simple enough
    private func calcMaxSpeed(){
        if self.path.count < 1{
            self.maxSpeed = 0
        }
        
        var currentMaxSpeed:Double = 0
        for possition in self.path{
            currentMaxSpeed = max(currentMaxSpeed, possition.speed)
        }
        self.maxSpeed = currentMaxSpeed
    }
}
