//
//  Activity.swift
//  ActivityTracker
//
//  Created by Ryan Pearson on 7/30/20.
//  Copyright © 2020 Ryan Pearson. All rights reserved.
//

import Foundation
import CoreLocation
import os.log

//WILL NEED TO EXTEND CLASSES FOR SAVING
public class Activity: NSObject, NSCoding{
    
    //MARK: Properties
    private(set) var path: [PosTime]!
    private(set) var avePace: Double!//miliseconds/m
    private(set) var distance: Double!
    private(set) var time: Double!//time in miliseconds
    
    //used for easy selection of activity
    private enum ActivityType{
        static let run = "Run"
    }
    
    private struct PropertyKey{
        static let path = "path"
        static let averagePace = "averagePace"
        static let distance = "distance"
        static let time = "time"
    }
    
    //MARK: Inits
    init(path: [PosTime]){
        super.init()
        self.path = path
        self.calcDistance()
        self.calcTime()
        self.calcAvePace()
        
    }
    
    //MARK: private methods
    private func calcDistance(){
        if path.count < 2 {
            os_log("not enough points in path to calculate distance", type: .debug)
            self.distance = 0.0
            return
        }
        var dist:Double = 0
        var prevLocation: CLLocation = path[0].pos
        for i in 1..<path.count{
            let nextLocation:CLLocation = path[i].pos
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
        self.time = path[path.count-1].time
    }
    
    private func calcAvePace(){
        if distance <= 0 || time <= 0{
            os_log("can't calculate pace of a negitive distance or time", type: .error)
            self.avePace = 0.0
            return
        }
        self.avePace = time/distance
    }
    
    //MARK: NSCoding
    public func encode(with coder: NSCoder) {
        coder.encode(path, forKey: PropertyKey.path)
        coder.encode(distance, forKey: PropertyKey.distance)
        coder.encode(avePace, forKey: PropertyKey.averagePace)
        coder.encode(time, forKey: PropertyKey.time)
    }
    
    public required init?(coder: NSCoder) {
        //long gaurd statement to decode all properties
        guard let path = coder.decodeObject(forKey: PropertyKey.path) as? [PosTime] , let distance = coder.decodeObject(forKey: PropertyKey.distance) as? Double, let avePace = coder.decodeObject(forKey: PropertyKey.averagePace) as? Double, let time = coder.decodeObject(forKey: PropertyKey.time) as? Double else{
            
            os_log("could not decode object", type: .error)
            return nil
        }
        self.path = path
        self.distance = distance
        self.avePace = avePace
        self.time = time
    }
}
