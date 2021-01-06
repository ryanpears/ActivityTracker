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

//TODO: eventually need to switch entirely to CoreData sicne NSKeyedArchiever is getting removed at some point.
//TODO: when switching entirely to CoreData make this class be a super class to be inhertied by different activities such as run, hike, bike, etc.

public class Activity: NSObject, NSSecureCoding{
    public static var supportsSecureCoding: Bool = true
    
   
    //MARK: Properties
    private(set) var path: [PosTime]!
    private(set) var avePace: Double!//m/millisecond possibly change per different activitys
    private(set) var distance: Double!//distance in Meters
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
        //possibly move to measurementUtils
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
        self.avePace = distance/time
    }
    
    //MARK: NSCoding
    //OK so i found a thread that pretty much said this will not work
    //like at all. so idk why 2 load as 0s but i guess i need to learn
    //codable or some shit that isn't NSKeyedArchiver.
    public func encode(with coder: NSCoder) {
        //now know keyedCoding is possible at least should be
        /*if coder.allowsKeyedCoding {
            os_log("yay if this doesn't print im fucked")
        }else{
            os_log("fuck")
        }*/
        
        coder.encode(self.path as NSArray, forKey: PropertyKey.path)
        coder.encode(NSNumber(value: self.distance), forKey: PropertyKey.distance)
        coder.encode(NSNumber(value: self.avePace), forKey: PropertyKey.averagePace)
        coder.encode(NSNumber(value:self.time), forKey: PropertyKey.time)
        
    }
    
    public required init?(coder: NSCoder) {
        //long gaurd statement to decode all properties
       //must use coder.decodeObject(of: forkey:
        guard let distCode = coder.decodeObject(of: NSNumber.self, forKey: PropertyKey.distance) else{
            os_log("could not decode distance")
            return nil
        }
        guard let timeCode = coder.decodeObject(of: NSNumber.self, forKey: PropertyKey.time) else{
            os_log("could not decode time")
            return nil
        }
        guard let paceCode = coder.decodeObject(of: NSNumber.self, forKey: PropertyKey.averagePace) else{
            os_log("could not decode pace")
            return nil
        }
        guard let pathCode = coder.decodeObject(of: [NSArray.self, PosTime.self], forKey: PropertyKey.path) else{
            os_log("could not decode path")
            return nil
        }
        os_log("actually got values", type: .debug)
        self.path = pathCode as! [PosTime]
        self.distance = distCode.doubleValue
        self.avePace = paceCode.doubleValue
        self.time = timeCode.doubleValue
        super.init()
    }
}
